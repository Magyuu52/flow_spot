class Post < ApplicationRecord
  scope :latest, -> { order(created_at: :desc) }
  scope :old, -> { order(created_at: :asc) }
  scope :most_favorited, -> { includes(:liked_users).sort_by { |x| x.liked_users.includes(:likes).size }.reverse }
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

  def likes_count
    return Like.where(post_id: self.id).count
  end

  def liked?(user)
    likes.exists?(user_id: user.id)
  end

  def self.search(search)
    if search != ""
      Post.where(['title LIKE(?) OR address LIKE(?) OR user_name LIKE(?)', "%#{search}%", "%#{search}%", "%#{search}%"])
    else
      Post.all
    end
  end
end
