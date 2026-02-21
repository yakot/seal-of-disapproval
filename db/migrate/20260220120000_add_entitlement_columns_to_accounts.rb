# frozen_string_literal: true

class AddEntitlementColumnsToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :entitlement_source, :string, null: false, default: 'stripe'
    add_column :accounts, :entitlement_expires_at, :datetime
    add_column :accounts, :entitlement_reason, :text
    add_column :accounts, :granted_by_admin_id, :bigint

    add_foreign_key :accounts, :users, column: :granted_by_admin_id, on_delete: :nullify
  end
end
