# frozen_string_literal: true

class NotificationJob < ApplicationJob
  queue_as :default

  retry_on Net::OpenTimeout, wait: :polynomially_longer, attempts: 3
  retry_on Net::SMTPServerBusy, wait: 10.seconds, attempts: 3

  discard_on ActiveJob::DeserializationError

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification
    return if notification.sent_at.present?

    NotificationMailer.with(notification: notification).notify.deliver_now
    notification.update!(sent_at: Time.current)
  end
end
