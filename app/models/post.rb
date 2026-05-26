# frozen_string_literal: true

class Post < ApplicationRecord
  scope :latest, -> { order(created_at: :desc) }
  scope :old, -> { order(created_at: :asc) }
  scope :most_favorited, -> {
    left_joins(:likes)
      .group("posts.id")
      .order("COUNT(likes.id) DESC")
  }
  validates :title, { presence: true, length: { maximum: 30 } }
  validates :content, length: { maximum: 500 }
  validates :address, presence: true
  validates_with PostRateLimitValidator
  has_one_attached :spot_image
  has_one_attached :flow_video
  validates :spot_image, blob: { content_type: :image }
  validates :flow_video, blob: { content_type: :video, size_range: 1..50.megabytes }
  geocoded_by :address
  after_validation :geocode_with_client, if: :address_changed?
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

  # ransack がクエリ生成に使える属性をホワイトリストで制限する。
  # ここに含まれないカラム（user_id, latitude 等）は検索パラメータに渡されても無視される。
  def self.ransackable_attributes(_auth_object = nil)
    %w[title address user_name created_at]
  end

  # ransack がJOINして検索できるアソシエーションを制限する。
  # user を許可することで「投稿者の経験レベル」等のモデル横断検索が可能になる。
  def self.ransackable_associations(_auth_object = nil)
    %w[user likes]
  end

  def self.with_filter(&block)
    block_given? ? yield(all) : all
  end

  private

  # GoogleMapsClient のリトライ付きジオコーディングを利用する。
  # Geocoder gem の geocode メソッドの代わりに、Faraday 経由で API を呼び出し
  # タイムアウト・5xx に対して exponential backoff でリトライする。
  def geocode_with_client(client: GoogleMapsClient.new)
    result = client.geocode(address)
    self.latitude  = result[:lat]
    self.longitude = result[:lng]
  rescue GoogleMapsClient::ApiError => e
    Rails.logger.warn("[Post#geocode] #{e.message}")
    errors.add(:address, "の位置情報を取得できませんでした。しばらくしてから再度お試しください")
    throw :abort
  end
end
