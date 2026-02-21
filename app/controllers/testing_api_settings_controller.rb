# frozen_string_literal: true

class TestingApiSettingsController < ApplicationController
  skip_authorization_check

  def index
    @webhook_url = current_account.webhook_urls.first_or_initialize
  end
end
