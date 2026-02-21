# frozen_string_literal: true

class SendSubmitterReminderEmailJob
  include Sidekiq::Job

  sidekiq_options queue: :mailers

  def perform(params = {})
    submitter = Submitter.find_by(id: params['submitter_id'])

    return if submitter.nil?
    return if submitter.completed_at?
    return if submitter.declined_at?
    return if submitter.submission.archived_at?
    return if submitter.template&.archived_at?
    return if submitter.email.blank?

    unless Accounts.can_send_emails?(submitter.account)
      Rollbar.warning("Skip reminder email: #{submitter.account.id}") if defined?(Rollbar)
      return
    end

    reminder_number = params['reminder_number'] || 1

    logger.info "[Reminders] Sending reminder ##{reminder_number} to #{submitter.email}"

    mail = SubmitterMailer.reminder_email(submitter)

    Submitters::ValidateSending.call(submitter, mail)

    mail.deliver_now!

    SubmissionEvent.create!(submitter:, event_type: 'send_reminder_email', data: { reminder_number: })

    submitter.reminders_sent_at ||= {}
    submitter.reminders_sent_at["reminder_#{reminder_number}"] = Time.current.iso8601
    submitter.save!

    logger.info "[Reminders] Reminder ##{reminder_number} sent to #{submitter.email}"
  end
end
