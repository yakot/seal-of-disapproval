# frozen_string_literal: true

class CreateIdentities < ActiveRecord::Migration[7.0]
  def change
    create_table :identities do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :email
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :image_url
      t.text :access_token
      t.datetime :expires_at
      t.text :refresh_token
      t.json :raw_info

      t.timestamps
    end

    add_index :identities, %i[provider uid], unique: true
    add_index :identities, :email
  end
end
