# frozen_string_literal: true

class CreateAttributionIds < ActiveRecord::Migration[7.1]
  def change
    create_table :attribution_ids do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :gclid
      t.string :gbraid
      t.string :wbraid
      t.string :fbclid
      t.string :twclid
      t.datetime :captured_at, null: false
      t.timestamps
    end
  end
end
