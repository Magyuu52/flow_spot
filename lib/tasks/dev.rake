# frozen_string_literal: true

namespace :dev do
  desc '開発用データを一括投入（冪等対応・新メンバーのセットアップ向け）'
  task seed: :environment do
    puts '=' * 50
    puts ' FLOW SPOT 開発用データセットアップ'
    puts '=' * 50
    puts ''

    ActiveRecord::Base.transaction do
      guest     = create_guest_user
      admin     = create_admin_user
      moderator = create_moderator_user
      users     = create_general_users
      all_users = [guest, admin, moderator] + users

      posts     = create_posts(users + [admin, moderator])
      create_relationships(all_users)
      create_likes(all_users, posts)
      create_notifications(all_users, posts)
    end

    print_summary
    print_login_info
  end

  desc '開発用データを全削除してからセットアップし直す'
  task reset: :environment do
    puts '⚠ 全データを削除します...'
    [Notification, Like, Relationship, Post, User].each(&:delete_all)
    ActiveStorage::Attachment.delete_all
    ActiveStorage::Blob.delete_all
    puts '  削除完了'
    puts ''
    Rake::Task['dev:seed'].invoke
  end

  private

  def create_guest_user
    user = User.find_or_create_by!(email: Constants::GUEST_EMAIL) do |u|
      u.name             = Constants::GUEST_NAME
      pw                 = User.generate_guest_password
      u.password         = pw
      u.password_confirm = pw
    end
    puts "[User] ゲスト: #{user.email}"
    user
  end

  def create_admin_user
    user = User.find_or_create_by!(email: 'admin@example.com') do |u|
      u.name             = '管理者ユーザー'
      u.password         = 'Admin1'
      u.password_confirm = 'Admin1'
      u.role             = :admin
      u.introduction     = '管理者アカウントです。全ての操作が可能です。'
      u.experience       = '3年以上'
    end
    user.update_column(:role, User.roles[:admin]) unless user.admin?
    puts "[User] 管理者: #{user.email} (role=admin)"
    user
  end

  def create_moderator_user
    user = User.find_or_create_by!(email: 'moderator@example.com') do |u|
      u.name             = 'モデレーター'
      u.password         = 'Mod123'
      u.password_confirm = 'Mod123'
      u.role             = :moderator
      u.introduction     = 'モデレーターです。投稿の削除が可能です。'
      u.experience       = '1〜2年'
    end
    user.update_column(:role, User.roles[:moderator]) unless user.moderator?
    puts "[User] モデレーター: #{user.email} (role=moderator)"
    user
  end

  def create_general_users
    experiences = Constants::VALID_EXPERIENCE_OPTIONS
    users = []

    5.times do |n|
      user = User.find_or_create_by!(email: "user#{n + 1}@example.com") do |u|
        u.name             = "開発ユーザー#{n + 1}"
        u.password         = 'Test1a'
        u.password_confirm = 'Test1a'
        u.experience       = experiences[n % experiences.size]
        u.introduction     = 'テスト用の一般ユーザーです。'
      end
      users << user
    end

    puts "[User] 一般ユーザー: #{users.size}人 (user1〜5@example.com)"
    users
  end

  def create_posts(authors)
    addresses = [
      { addr: '東京都渋谷区神宮前1-1', lat: 35.6702, lng: 139.7026 },
      { addr: '大阪府大阪市港区海岸通1丁目1', lat: 34.6551, lng: 135.4295 },
      { addr: '神奈川県横浜市中区山下町279',       lat: 35.4437, lng: 139.6500 },
      { addr: '東京都世田谷区駒沢公園1-1',        lat: 35.6265, lng: 139.6614 },
      { addr: '愛知県名古屋市東区東桜1丁目11-1',   lat: 35.1709, lng: 136.9116 },
      { addr: '兵庫県神戸市中央区波止場町2',       lat: 34.6843, lng: 135.1857 },
      { addr: '東京都墨田区亀沢1丁目1-11', lat: 35.6966, lng: 139.7980 },
      { addr: '大阪府大阪市北区扇町1丁目1', lat: 34.7032, lng: 135.5102 },
      { addr: '東京都千代田区神田和泉町1-300',     lat: 35.6989, lng: 139.7780 },
      { addr: '大阪府吹田市千里万博公園',          lat: 34.8106, lng: 135.5321 }
    ]

    Post.skip_callback(:validation, :after, :geocode_with_client)

    posts = []
    10.times do |n|
      author = authors[n % authors.size]
      spot = addresses[n]
      post = Post.find_or_create_by!(title: "スポット#{n + 1}") do |p|
        p.address   = spot[:addr]
        p.content   = "#{spot[:addr]}にある練習スポットです。初心者から上級者まで楽しめます。"
        p.user      = author
        p.user_name = author.name
        p.latitude  = spot[:lat]
        p.longitude = spot[:lng]
      end
      posts << post
    end

    puts "[Post] 投稿: #{posts.size}件"
    posts
  ensure
    Post.set_callback(:validation, :after, :geocode_with_client)
  end

  def create_relationships(users)
    count_before = Relationship.count

    users.each_with_index do |user, _idx|
      targets = users.reject { |u| u.id == user.id }.sample([2, users.size - 1].min)
      targets.each do |target|
        Relationship.find_or_create_by!(follower_id: user.id, followed_id: target.id)
      end
    end

    created = Relationship.count - count_before
    puts "[Relationship] フォロー関係: #{Relationship.count}件 (新規#{created}件)"
  end

  def create_likes(users, posts)
    count_before = Like.count

    users.each do |user|
      posts.sample(rand(2..5)).each do |post|
        Like.find_or_create_by!(user_id: user.id, post_id: post.id)
      end
    end

    created = Like.count - count_before
    puts "[Like] いいね: #{Like.count}件 (新規#{created}件)"
  end

  def create_notifications(_users, _posts)
    count_before = Notification.count

    likes = Like.includes(:post).limit(5)
    likes.each do |like|
      Notification.find_or_create_by!(
        recipient_id: like.post.user_id,
        notifiable_type: 'Like',
        notifiable_id: like.id
      )
    end

    relationships = Relationship.limit(5)
    relationships.each do |rel|
      Notification.find_or_create_by!(
        recipient_id: rel.followed_id,
        notifiable_type: 'Relationship',
        notifiable_id: rel.id
      )
    end

    created = Notification.count - count_before
    puts "[Notification] 通知: #{Notification.count}件 (新規#{created}件)"
  end

  def print_summary
    puts ''
    puts '-' * 50
    puts ' データ件数サマリ'
    puts '-' * 50
    puts "  Users:         #{User.count}"
    puts "  Posts:         #{Post.count}"
    puts "  Likes:         #{Like.count}"
    puts "  Relationships: #{Relationship.count}"
    puts "  Notifications: #{Notification.count}"
  end

  def print_login_info
    puts ''
    puts '-' * 50
    puts ' ログイン情報（パスワード）'
    puts '-' * 50
    puts '  ゲスト       : ゲストログインボタンを使用'
    puts '  管理者       : admin@example.com     / Admin1'
    puts '  モデレーター : moderator@example.com / Mod123'
    puts '  一般ユーザー : user1@example.com     / Test1a'
    puts '             〜 user5@example.com     / Test1a'
    puts ''
    puts '=' * 50
    puts ' セットアップ完了！'
    puts '=' * 50
  end
end
