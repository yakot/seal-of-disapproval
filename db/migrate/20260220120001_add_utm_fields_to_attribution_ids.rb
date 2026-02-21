# frozen_string_literal: true

class AddUtmFieldsToAttributionIds < ActiveRecord::Migration[8.1]
  def change
    add_column :attribution_ids, :utm_source, :string, if_not_exists: true
    add_column :attribution_ids, :utm_medium, :string, if_not_exists: true
    add_column :attribution_ids, :utm_campaign, :string, if_not_exists: true
    add_column :attribution_ids, :utm_content, :string, if_not_exists: true
    add_column :attribution_ids, :utm_term, :string, if_not_exists: true
    add_column :attribution_ids, :referrer, :string, if_not_exists: true
    add_column :attribution_ids, :landing_page, :string, if_not_exists: true
  end
end
