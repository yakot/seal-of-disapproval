# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  archived_at            :datetime
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  consumed_timestep      :integer
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           not null
#  encrypted_password     :string
#  failed_attempts        :integer          default(0), not null
#  first_name             :string
#  last_name              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  otp_required_for_login :boolean          default(FALSE), not null
#  otp_secret             :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :string           not null
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  unlock_token           :string
#  uuid                   :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_id             :bigint           not null
#
# Indexes
#
#  index_users_on_account_id            (account_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#  index_users_on_uuid                  (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class User < ApplicationRecord
  ROLES = [
    ADMIN_ROLE = 'admin'
  ].freeze

  EMAIL_REGEXP = /[^@;,<>\s]+@[^@;,<>\s]+/

  FULL_EMAIL_REGEXP =
    /\A[a-z0-9][.']?(?:(?:[a-z0-9_-]+[.+'])*[a-z0-9_-]+)*@(?:[a-z0-9]+[.-])*[a-z0-9]+\.[a-z]{2,}\z/i

  has_one_attached :signature
  has_one_attached :initials

  belongs_to :account
  has_one :access_token, dependent: :destroy
  has_one :attribution_id, dependent: :destroy
  has_many :access_tokens, dependent: :destroy
  has_many :templates, dependent: :destroy, foreign_key: :author_id, inverse_of: :author
  has_many :template_folders, dependent: :destroy, foreign_key: :author_id, inverse_of: :author
  has_many :user_configs, dependent: :destroy
  has_many :encrypted_configs, dependent: :destroy, class_name: 'EncryptedUserConfig'
  has_many :email_messages, dependent: :destroy, foreign_key: :author_id, inverse_of: :author

  has_many :identities, dependent: :destroy

  devise :two_factor_authenticatable, :recoverable, :rememberable, :validatable, :trackable, :lockable,
         :omniauthable, omniauth_providers: %i[google_oauth2 microsoft_graph]

  attr_accessor :skip_password_validation

  attribute :role, :string, default: ADMIN_ROLE
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :admins, -> { where(role: ADMIN_ROLE) }

  validates :email, format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\z/ }

  def access_token
    super || build_access_token.tap(&:save!)
  end

  def active_for_authentication?
    super && !archived_at? && !account.archived_at?
  end

  def authenticatable_salt
    encrypted_password.present? ? super : "#{id}-#{created_at}"
  end

  def remember_me
    true
  end

  def sidekiq?
    return true if Rails.env.development?

    role == 'admin'
  end

  def self.sign_in_after_reset_password
    if PasswordsController::Current.user.present?
      !PasswordsController::Current.user.otp_required_for_login
    else
      true
    end
  end

  def initials
    [first_name&.first, last_name&.first].compact_blank.join.upcase
  end

  def full_name
    [first_name, last_name].compact_blank.join(' ')
  end

  def friendly_name
    if full_name.present?
      %("#{full_name.delete('"')}" <#{email}>)
    else
      email
    end
  end

  def has_oauth_provider?(provider)
    identities.exists?(provider: provider.to_s)
  end

  def self.from_omniauth(auth, account: nil)
    identity = Identity.find_by(provider: auth.provider, uid: auth.uid)

    if identity
      identity.update(
        email: auth.info.email,
        name: auth.info.name,
        first_name: auth.info.first_name,
        last_name: auth.info.last_name,
        image_url: auth.info.image,
        access_token: auth.credentials&.token,
        expires_at: auth.credentials&.expires_at ? Time.at(auth.credentials.expires_at) : nil,
        refresh_token: auth.credentials&.refresh_token
      )
      return identity.user
    end

    email = auth.info.email&.downcase
    user = User.find_by(email:) if email.present?

    if user.nil?
      user = User.new(
        email:,
        first_name: auth.info.first_name || auth.info.name&.split&.first,
        last_name: auth.info.last_name || auth.info.name&.split&.last,
        account:,
        uuid: SecureRandom.uuid
      )
      user.skip_password_validation = true
      user.save!
    end

    user.identities.create!(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      name: auth.info.name,
      first_name: auth.info.first_name,
      last_name: auth.info.last_name,
      image_url: auth.info.image,
      access_token: auth.credentials&.token,
      expires_at: auth.credentials&.expires_at ? Time.at(auth.credentials.expires_at) : nil,
      refresh_token: auth.credentials&.refresh_token
    )

    user
  end

  protected

  def password_required?
    return false if skip_password_validation

    identities.empty? && super
  end
end
