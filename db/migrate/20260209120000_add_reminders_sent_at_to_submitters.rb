# frozen_string_literal: true

class AddRemindersSentAtToSubmitters < ActiveRecord::Migration[8.1]
  class MigrationSubmitter < ApplicationRecord
    self.table_name = 'submitters'
  end

  def change
    add_column :submitters, :reminders_sent_at, :text

    MigrationSubmitter.where(reminders_sent_at: nil).update_all(reminders_sent_at: '{}')

    change_column_null :submitters, :reminders_sent_at, false
  end
end
