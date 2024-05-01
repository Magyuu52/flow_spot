class User < ApplicationRecord
  EMAIL_REGEXP = /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[\d])\w{6,12}\z/

  validates :name, { presence: true, length: { minimum: 1, maximum: 20 } }
  validates :introduction, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :password, presence: true, format: { with: VALID_PASSWORD_REGEX, message: "は半角6~12文字英大文字・小文字・数字それぞれ1文字以上含む必要があります" }
  validate :check_password
  has_one_attached :image
  validates :image, blob: { content_type: :image, size_range: 0..5.megabytes }
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followings, through: :relationships, source: :followed
  has_many :followers, through: :reverse_of_relationships, source: :follower

  def posts
    return Post.where(user_id: self.id)
  end

  def follow(user_id)
    relationships.create(followed_id: user_id)
  end

  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end

  def following?(user)
    followings.include?(user)
  end

  def self.search(search)
    if search != ""
      User.where('name LIKE(?)', "%#{search}%")
    else
      User.all
    end
  end

  def check_password
    if password_confirm != password
      errors.add(:password_confirm, "が一致しません。正しく入力してください")
    end
  end
end
