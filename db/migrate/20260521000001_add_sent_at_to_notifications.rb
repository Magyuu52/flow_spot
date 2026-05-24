# frozen_string_literal: true

class AddSentAtToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :sent_at, :datetime
  end
end
