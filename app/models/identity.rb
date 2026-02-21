# frozen_string_literal: true

# == Schema Information
#
# Table name: identities
#
#  id            :bigint           not null, primary key
#  access_token  :text
#  email         :string
#  expires_at    :datetime
#  first_name    :string
#  image_url     :string
#  last_name     :string
#  name          :string
#  provider      :string           not null
#  raw_info      :json
#  refresh_token :text
#  uid           :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_identities_on_email             (email)
#  index_identities_on_provider_and_uid  (provider,uid) UNIQUE
#  index_identities_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Identity < ApplicationRecord
  belongs_to :user

  encrypts :access_token, deterministic: false
  encrypts :refresh_token, deterministic: false

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  scope :google, -> { where(provider: 'google_oauth2') }
  scope :microsoft, -> { where(provider: 'microsoft_graph') }

  def token_expired?
    expires_at.present? && expires_at < Time.current
  end
end
