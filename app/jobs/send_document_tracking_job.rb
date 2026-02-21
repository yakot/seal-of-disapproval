# frozen_string_literal: true

class SendDocumentTrackingJob
  include Sidekiq::Job

  sidekiq_options queue: :tracking, retry: 3

  def perform(params = {})
    event_name = params['event_name']
    return if event_name.blank?

    user = resolve_user(params)
    return unless user

    event_data = (params['data'] || {}).symbolize_keys

    # GA4 Measurement Protocol
    begin
      Tracking::Ga4MeasurementProtocol.track_event(
        user: user,
        event_name: event_name,
        params: event_data
      )
    rescue StandardError => e
      Rails.logger.error("Document tracking GA4 error: #{e.message}")
    end

    # Customer.io — identify + event
    begin
      Tracking::Customerio.identify(user: user)
      Tracking::Customerio.track(
        user: user,
        event_name: event_name,
        data: event_data
      )
    rescue StandardError => e
      Rails.logger.error("Document tracking Customer.io error: #{e.message}")
    end

    # Meta CAPI
    begin
      Tracking::MetaCapi.send_event(
        event_name: event_name,
        external_id: user.id,
        custom_data: event_data
      )
    rescue StandardError => e
      Rails.logger.error("Document tracking Meta CAPI error: #{e.message}")
    end
  end

  private

  def resolve_user(params)
    return User.find_by(id: params['user_id']) if params['user_id'].present?

    if params['submission_id'].present?
      submission = Submission.find_by(id: params['submission_id'])
      return submission.created_by_user || submission.template&.author if submission
    end

    if params['submitter_id'].present?
      submitter = Submitter.find_by(id: params['submitter_id'])
      if submitter
        submission = submitter.submission
        return submission.created_by_user || submission.template&.author
      end
    end

    nil
  end
end
