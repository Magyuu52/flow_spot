# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def notify
    @notification = params[:notification]
    @recipient = @notification.recipient
    @notifiable = @notification.notifiable

    mail(
      to: @recipient.email,
      subject: notification_subject
    )
  end

  private

  def notification_subject
    case @notifiable
    when Like
      'あなたの投稿にいいねがつきました'
    when Relationship
      '新しいフォロワーがいます'
    else
      '新しい通知があります'
    end
  end
end
