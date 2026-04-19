# frozen_string_literal: true

class Post < ApplicationRecord
  scope :latest, -> { order(created_at: :desc) }
  scope :old, -> { order(created_at: :asc) }
  scope :most_favorited, -> { Post.sorted_by_likes_count }
  validates :title, { presence: true, length: { maximum: 30 } }
  validates :content, length: { maximum: 500 }
  validates :address, presence: true
  has_one_attached :spot_image
  has_one_attached :flow_video
  validates :spot_image, blob: { content_type: :image }
  validates :flow_video, blob: { content_type: :video, size_range: 1..50.megabytes }
  geocoded_by :address
  after_validation :geocode
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  def user
    return User.find_by(id: self.user_id)
  end

  # 投稿者情報のセットをモデルの責務として集約する
  def assign_author(user)
    self.user_id   = user.id
    self.user_name = user.name
  end

  def likes_count
    likes.count
  end

  def liked?(user)
    likes.exists?(user_id: user.id)
  end

  def self.search(search)
    return all if search.blank?

    keyword    = "%#{search}%"
    conditions = ["title LIKE(?) OR address LIKE(?) OR user_name LIKE(?)", keyword, keyword, keyword]
    where(conditions)
  end

private
  def self.sorted_by_likes_count
    posts_with_liked_users = includes(:liked_users)
    posts_with_liked_users.sort_by { |post| post.liked_users.size }.reverse
  end
end
