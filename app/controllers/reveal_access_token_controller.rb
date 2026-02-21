# frozen_string_literal: true

class RevealAccessTokenController < ApplicationController
  def show
    authorize!(:manage, current_user.access_token)
    reveal_access_token
  end

  def create
    authorize!(:manage, current_user.access_token)
    reveal_access_token
  end

  private

  def reveal_access_token
    render turbo_stream: turbo_stream.replace(:access_token_container,
                                              partial: 'reveal_access_token/access_token',
                                              locals: { token: current_user.access_token.token })
  end
end
