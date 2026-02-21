# frozen_string_literal: true

class SelfHostController < ApplicationController
  skip_authorization_check

  def index; end
end
