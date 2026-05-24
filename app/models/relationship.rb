# frozen_string_literal: true

class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :follower_id, presence: true, uniqueness: { scope: :followed_id }
  validates :followed_id, presence: true

  after_create_commit :enqueue_notification

  private

  def enqueue_notification
    notification = Notification.create!(recipient: followed, notifiable: self)
    NotificationJob.perform_later(notification.id)
  end
end
