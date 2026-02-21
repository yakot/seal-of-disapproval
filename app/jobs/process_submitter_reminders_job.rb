# frozen_string_literal: true

class ProcessSubmitterRemindersJob
  include Sidekiq::Job

  sidekiq_options queue: :recurrent, retry: false

  INTERVAL = ENV.fetch('REMINDER_CHECK_INTERVAL', 60).to_i

  DURATION_TO_SECONDS = {
    'one_hour' => 1.hour,
    'two_hours' => 2.hours,
    'four_hours' => 4.hours,
    'eight_hours' => 8.hours,
    'twelve_hours' => 12.hours,
    'twenty_four_hours' => 24.hours,
    'two_days' => 2.days,
    'three_days' => 3.days,
    'four_days' => 4.days,
    'five_days' => 5.days,
    'six_days' => 6.days,
    'seven_days' => 7.days,
    'eight_days' => 8.days,
    'fifteen_days' => 15.days,
    'twenty_one_days' => 21.days,
    'thirty_days' => 30.days
  }.freeze

  REMINDER_KEYS = %w[first_duration second_duration third_duration].freeze

  def perform
    logger.info '[Reminders] ProcessSubmitterRemindersJob started'

    Account.find_each do |account|
      process_account_reminders(account)
    end

    logger.info '[Reminders] ProcessSubmitterRemindersJob finished'
  ensure
    Sidekiq::Client.push(
      'class' => self.class.name,
      'args' => [],
      'queue' => 'recurrent',
      'at' => Time.now.to_f + INTERVAL
    )
    logger.info "[Reminders] Next run scheduled in #{INTERVAL}s"
  end

  private

  def process_account_reminders(account)
    reminder_config = AccountConfig.find_by(account:, key: AccountConfig::SUBMITTER_REMINDERS)

    return if reminder_config.nil?
    return if reminder_config.value.blank?

    durations = parse_durations(reminder_config.value)

    return if durations.empty?

    logger.info "[Reminders] Account #{account.id}: #{durations.size} reminder(s) configured"

    pending_submitters(account).find_each do |submitter|
      submitter.with_lock do
        process_submitter_reminders(submitter, durations)
      end
    end
  end

  def parse_durations(config_value)
    REMINDER_KEYS.each_with_index.filter_map do |key, index|
      duration_key = config_value[key]
      next if duration_key.blank?

      duration = DURATION_TO_SECONDS[duration_key]
      next if duration.nil?

      { reminder_number: index + 1, duration:, key: }
    end
  end

  def pending_submitters(account)
    account.submitters
           .where(completed_at: nil, declined_at: nil)
           .where.not(email: [nil, ''])
           .where.not(sent_at: nil)
           .joins(:submission)
           .where(submissions: { archived_at: nil })
  end

  def process_submitter_reminders(submitter, durations)
    reminders_sent = submitter.reminders_sent_at || {}

    durations.each do |reminder|
      reminder_key = "reminder_#{reminder[:reminder_number]}"

      next if reminders_sent[reminder_key].present?

      reference_time = last_sent_time(submitter, reminders_sent, reminder[:reminder_number])
      time_since_reference = Time.current - reference_time

      if time_since_reference >= reminder[:duration]
        # Mark reminder as sent immediately to prevent duplicate sends
        # on the next 60s cycle before the email job completes.
        submitter.reminders_sent_at ||= {}
        submitter.reminders_sent_at[reminder_key] = Time.current.iso8601
        submitter.save!

        logger.info "[Reminders] Queuing reminder ##{reminder[:reminder_number]} for submitter #{submitter.id} (#{submitter.email})"

        SendSubmitterReminderEmailJob.perform_async(
          'submitter_id' => submitter.id,
          'reminder_number' => reminder[:reminder_number]
        )

        break
      else
        remaining = reminder[:duration] - time_since_reference
        logger.info "[Reminders] Submitter #{submitter.id}: reminder ##{reminder[:reminder_number]} not due yet (#{(remaining / 60).round}min remaining)"
      end
    end
  end

  def last_sent_time(submitter, reminders_sent, current_reminder_number)
    if current_reminder_number == 1
      submitter.sent_at
    else
      previous_key = "reminder_#{current_reminder_number - 1}"
      previous_sent = reminders_sent[previous_key]

      previous_sent.present? ? Time.zone.parse(previous_sent) : submitter.sent_at
    end
  end
end
