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

  def self.search(condition)
    return all if condition.blank_keyword?

    pattern    = condition.like_pattern
    conditions = ["title LIKE(?) OR address LIKE(?) OR user_name LIKE(?)", pattern, pattern, pattern]
    where(conditions)
  end

  # 現在のスコープ（ActiveRecord::Relation）をブロックに渡し、
  # 追加条件を合成して返すスコープ合成ヘルパー。
  # ブロックが渡されない場合は全件スコープをそのまま返す。
  #
  # 例:
  #   Post.with_filter { |posts| posts.where(user_id: id) }
  #   Post.with_filter { |posts| posts.latest.limit(10) }
  #   Post.latest.merge(Post.with_filter { |posts| posts.where(address: "東京") })
  def self.with_filter(&block)
    block_given? ? yield(all) : all
  end

private
  # sort_by のキーをマイナスにすることで降順ソートを表現し、reverse の追加パスを省く
  def self.sorted_by_likes_count
    includes(:liked_users).sort_by { |post| -post.liked_users.size }
  end
end
