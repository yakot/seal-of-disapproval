# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    account = user.account

    can %i[read create update], Template, Abilities::TemplateConditions.collection(user) do |template|
      Abilities::TemplateConditions.entity(template, user:, ability: 'manage')
    end

    can :destroy, Template, account_id: user.account_id
    can :manage, TemplateFolder, account_id: user.account_id
    can :manage, TemplateSharing, template: { account_id: user.account_id }
    can :manage, Submission, account_id: user.account_id
    can :manage, Submitter, account_id: user.account_id
    can :manage, User, account_id: user.account_id
    can :manage, EncryptedConfig, account_id: user.account_id
    can :manage, EncryptedUserConfig, user_id: user.id
    can :manage, AccountConfig, account_id: user.account_id
    can :manage, UserConfig, user_id: user.id
    can :manage, Account, id: user.account_id

    # API - conditional on subscription
    if !Docuseal.feature_restricted?('api') || account.subscribed?
      can :manage, AccessToken, user_id: user.id
    end

    # Webhooks - conditional on subscription
    if !Docuseal.feature_restricted?('webhooks') || account.subscribed?
      can :manage, WebhookUrl, account_id: user.account_id
    end

    # SSO - conditional on subscription
    if !Docuseal.feature_restricted?('sso') || account.subscribed?
      can :manage, :saml_sso
    end

    # Feature access symbols - for settings tab restrictions
    can(:access, :settings_email) if !Docuseal.feature_restricted?('email') || account.subscribed?
    can(:access, :settings_storage) if !Docuseal.feature_restricted?('storage') || account.subscribed?
    can(:access, :settings_notifications) if !Docuseal.feature_restricted?('notifications') || account.subscribed?
    can(:access, :settings_esign) if !Docuseal.feature_restricted?('esign') || account.subscribed?
    can(:access, :settings_personalization) if !Docuseal.feature_restricted?('personalization') || account.subscribed?
    can(:access, :settings_users) if !Docuseal.feature_restricted?('users') || account.subscribed?

    # Premium features - available to all users
    can :manage, :personalization_advanced
    can :manage, :countless
  end
end
