# frozen_string_literal: true

class AttributionIdsController < ApplicationController
  skip_authorization_check

  def create
    return head :no_content if current_user.attribution_id.present?

    attribution = current_user.build_attribution_id(
      gclid: params[:gclid],
      gbraid: params[:gbraid],
      wbraid: params[:wbraid],
      fbclid: params[:fbclid],
      twclid: params[:twclid],
      ga_client_id: params[:ga_client_id],
      utm_source: params[:utm_source],
      utm_medium: params[:utm_medium],
      utm_campaign: params[:utm_campaign],
      utm_content: params[:utm_content],
      utm_term: params[:utm_term],
      referrer: params[:referrer],
      landing_page: params[:landing_page],
      captured_at: Time.current
    )

    if attribution.save
      Tracking::Customerio.identify(user: current_user)
      head :created
    else
      head :no_content
    end
  rescue ActiveRecord::RecordNotUnique
    head :no_content
  end
end
