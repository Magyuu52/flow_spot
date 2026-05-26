# frozen_string_literal: true

class PostRateLimitValidator < ActiveModel::Validator
  MAX_POSTS_PER_HOUR = 10

  def validate(record)
    return unless record.new_record?
    return if record.user.blank?

    recent_count = record.user.posts
                         .where(created_at: 1.hour.ago..)
                         .count

    return unless recent_count >= MAX_POSTS_PER_HOUR

    record.errors.add(:base, '投稿頻度が上限を超えています。しばらく待ってから再度お試しください')
  end
end
