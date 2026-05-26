# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { where(read: false) }
  scope :unsent, -> { where(sent_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update!(read: true)
  end

  def sent?
    sent_at.present?
  end
end
