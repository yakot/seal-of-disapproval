# frozen_string_literal: true

require 'sidekiq/web' if defined?(Puma)
require 'sidekiq/api'

if !ENV['SIDEKIQ_BASIC_AUTH_PASSWORD'].to_s.empty? && defined?(Sidekiq::Web)
  Sidekiq::Web.use(Rack::Auth::Basic) do |_, password|
    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(password),
      Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_BASIC_AUTH_PASSWORD'))
    )
  end
end

Sidekiq.strict_args!

Sidekiq.configure_server do |config|
  config.on(:startup) do
    # Bootstrap the self-scheduling reminder job if not already queued or scheduled
    scheduled = Sidekiq::ScheduledSet.new.any? { |j| j.klass == 'ProcessSubmitterRemindersJob' }
    queued = Sidekiq::Queue.new('recurrent').any? { |j| j.klass == 'ProcessSubmitterRemindersJob' }

    unless scheduled || queued
      Sidekiq::Client.push(
        'class' => 'ProcessSubmitterRemindersJob',
        'args' => [],
        'queue' => 'recurrent'
      )
      Sidekiq.logger.info '[Reminders] Bootstrapped ProcessSubmitterRemindersJob from initializer'
    end
  end
end
