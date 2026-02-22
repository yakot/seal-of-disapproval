# frozen_string_literal: true

class AddGaClientIdToAttributionIds < ActiveRecord::Migration[8.1]
  def change
    add_column :attribution_ids, :ga_client_id, :string unless column_exists?(:attribution_ids, :ga_client_id)
  end
end
