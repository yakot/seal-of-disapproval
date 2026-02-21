# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registrations API', type: :request do
  # Note: Tests for multitenant mode require MULTITENANT=true env var at boot time.
  # Runtime stubbing of Docuseal.multitenant? causes route reload conflicts with ActiveStorage.
  # For full multitenant testing, run tests with MULTITENANT=true environment variable.

  describe 'GET /registration/new' do
    context 'when not in multitenant mode (default)' do
      it 'redirects to root' do
        get new_registration_path

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /registration' do
    context 'when not in multitenant mode (default)' do
      it 'redirects to root' do
        get registration_path

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST /registration' do
    let(:valid_params) do
      {
        user: {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          password: 'password123'
        },
        account: {
          name: 'Acme Inc',
          timezone: 'UTC',
          locale: 'en-US'
        }
      }
    end

    context 'when not in multitenant mode (default)' do
      it 'redirects to root' do
        post registration_path, params: valid_params

        expect(response).to redirect_to(root_path)
      end

      it 'does not create an account or user' do
        expect {
          post registration_path, params: valid_params
        }.not_to change(Account, :count)

        expect(User.count).to eq(0)
      end
    end
  end
end
