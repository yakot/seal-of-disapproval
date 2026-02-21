# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                     :bigint           not null, primary key
#  archived_at            :datetime
#  locale                 :string           not null
#  name                   :string           not null
#  timezone               :string           not null
#  uuid                   :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  entitlement_expires_at :datetime
#  entitlement_reason     :text
#  entitlement_source     :string           default("stripe"), not null
#  stripe_customer_id     :string
#  stripe_subscription_id :string
#  granted_by_admin_id    :bigint
#
# Indexes
#
#  index_accounts_on_stripe_customer_id  (stripe_customer_id) UNIQUE
#  index_accounts_on_uuid                (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (granted_by_admin_id => users.id) ON DELETE => nullify
#
class Account < ApplicationRecord
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  has_many :users, dependent: :destroy
  has_many :encrypted_configs, dependent: :destroy
  has_many :account_configs, dependent: :destroy
  has_many :email_messages, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :template_folders, dependent: :destroy
  has_one :default_template_folder, -> { where(name: TemplateFolder::DEFAULT_NAME) },
          class_name: 'TemplateFolder', dependent: :destroy, inverse_of: :account
  has_many :submissions, dependent: :destroy
  has_many :submitters, dependent: :destroy
  has_many :account_linked_accounts, dependent: :destroy
  has_many :email_events, dependent: :destroy
  has_many :webhook_urls, dependent: :destroy
  has_many :webhook_events, dependent: nil
  has_many :account_accesses, dependent: :destroy
  has_many :account_testing_accounts, -> { testing }, dependent: :destroy,
                                                      class_name: 'AccountLinkedAccount',
                                                      inverse_of: :account
  has_one :linked_account_account, dependent: :destroy,
                                   foreign_key: :linked_account_id,
                                   class_name: 'AccountLinkedAccount',
                                   inverse_of: :linked_account
  has_many :linked_account_accounts, dependent: :destroy,
                                     foreign_key: :linked_account_id,
                                     class_name: 'AccountLinkedAccount',
                                     inverse_of: :linked_account
  has_many :linked_accounts, through: :account_linked_accounts
  has_many :testing_accounts, through: :account_testing_accounts, source: :linked_account
  has_many :active_users, -> { active }, dependent: :destroy,
                                         inverse_of: :account, class_name: 'User'

  belongs_to :granted_by_admin, class_name: 'User', optional: true

  has_one_attached :logo

  attribute :timezone, :string, default: 'UTC'
  attribute :locale, :string, default: 'en-US'

  scope :active, -> { where(archived_at: nil) }

  def testing?
    linked_account_account&.testing?
  end

  def subscribed?
    return linked_account_account&.account&.subscribed? || false if testing?

    if entitlement_source == 'stripe'
      stripe_subscription_id.present?
    else
      entitlement_expires_at.nil? || entitlement_expires_at > Time.current
    end
  end

  def tz_info
    @tz_info ||= TZInfo::Timezone.get(ActiveSupport::TimeZone::MAPPING[timezone] || timezone)
  end

  def default_template_folder
    super || build_default_template_folder(name: TemplateFolder::DEFAULT_NAME,
                                           author_id: users.minimum(:id)).tap(&:save!)
  end
end
