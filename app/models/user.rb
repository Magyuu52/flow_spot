# frozen_string_literal: true

class User < ApplicationRecord
  # Regexp はRubyがデフォルトでfreezeするが、意図を明示するために付与する
  EMAIL_REGEXP = URI::MailTo::EMAIL_REGEXP
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[\d])\w{6,12}\z/

  enum :role, { general: 0, moderator: 1, admin: 2 }

  validates :name, { presence: true, length: { minimum: 1, maximum: 20 } }
  validates :introduction, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  PASSWORD_FORMAT_MSG = 'は半角6~12文字英大文字・小文字・数字それぞれ1文字以上含む必要があります'
  validates :password, presence: true,
                       format: { with: VALID_PASSWORD_REGEX, message: PASSWORD_FORMAT_MSG },
                       unless: :oauth_user?
  validate :check_password, unless: :oauth_user?
  has_one_attached :image
  validates :image, blob: { content_type: :image, size_range: 0..(5.megabytes) }
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :relationships, class_name: 'Relationship', foreign_key: 'follower_id',
                           dependent: :destroy, inverse_of: :follower
  has_many :reverse_of_relationships, class_name: 'Relationship', foreign_key: 'followed_id',
                                      dependent: :destroy, inverse_of: :followed
  has_many :followings, through: :relationships, source: :followed
  has_many :followers, through: :reverse_of_relationships, source: :follower
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy, inverse_of: :recipient

  def follow(user_id)
    relationships.create(followed_id: user_id)
  end

  def unfollow(user_id)
    relationships.find_by(followed_id: user_id).destroy
  end

  def following?(user)
    followings.include?(user)
  end

  def liked_posts
    Post.joins(:likes).where(likes: { user_id: id })
  end

  # ransack がクエリ生成に使える属性をホワイトリストで制限する。
  # password, email 等の機密カラムは含めず、情報漏洩・列挙攻撃を防止する。
  def self.ransackable_attributes(_auth_object = nil)
    %w[name experience created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[posts]
  end

  def self.find_or_create_from_oauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.name     = auth.info.name
      user.email    = auth.info.email
      user.password = generate_guest_password
      user.password_confirm = user.password
    end
  end

  def check_password
    return if password == password_confirm

    errors.add(:password_confirm, 'が一致しません。正しく入力してください')
  end

  def oauth_user?
    provider.present?
  end

  def guest?
    email == Constants::GUEST_EMAIL
  end

  # バリデーション（英大文字・英小文字・数字を各1文字以上含む）を確実に満たすパスワードを生成する
  def self.generate_guest_password
    base      = SecureRandom.alphanumeric(10) # ランダムな英数字10文字（英大文字を含む可能性あり）
    lowercase = [*'a'..'z'].sample            # バリデーション要件: 英小文字を確実に含める
    digit     = [*'0'..'9'].sample            # バリデーション要件: 数字を確実に含める
    base + lowercase + digit
  end

  # トークンの有効期限内かどうかを判定する。
  # Time.current を使うことで config.time_zone（Asia/Tokyo）を尊重し、
  # Time.now（OS タイムゾーン依存）による 9 時間ズレのリスクを避ける。
  # Range#cover? は両端との比較のみで判定するため include? より高速。
  def self.token_still_valid?(issued_at, valid_minutes: 15)
    valid_window = issued_at..(issued_at + valid_minutes.minutes)
    valid_window.cover?(Time.current)
  end
end
