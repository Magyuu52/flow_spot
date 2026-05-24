# frozen_string_literal: true

class Like < ApplicationRecord
  validates :user_id, presence: true
  validates :post_id, presence: true
  validates_uniqueness_of :post_id, scope: :user_id
  belongs_to :user
  belongs_to :post
  has_many :notifications, as: :notifiable, dependent: :destroy

  after_create_commit :enqueue_notification

  private

  def enqueue_notification
    return if user_id == post.user_id

    notification = Notification.create!(recipient: post.user, notifiable: self)
    NotificationJob.perform_later(notification.id)
  end
end
