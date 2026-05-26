# frozen_string_literal: true

ActiveStorage::AnalyzeJob.queue_adapter = :inline
ActiveStorage::PurgeJob.queue_adapter = :inline

puts "=== Seeding start ==="

# ゲストユーザー（ID固定のため find_or_create_by）
guest = User.find_or_create_by!(email: Constants::GUEST_EMAIL) do |u|
  u.name             = Constants::GUEST_NAME
  guest_pw           = User.generate_guest_password
  u.password         = guest_pw
  u.password_confirm = guest_pw
end
puts "  Guest: #{guest.email} (id=#{guest.id})"

# 管理者ユーザー
admin = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.name             = "管理者"
  u.password         = "Admin1"
  u.password_confirm = "Admin1"
  u.role             = :admin
end
admin.update_column(:role, User.roles[:admin]) unless admin.admin?
puts "  Admin: #{admin.email} (id=#{admin.id}, role=#{admin.role})"

# モデレーター
moderator = User.find_or_create_by!(email: "moderator@example.com") do |u|
  u.name             = "モデレーター"
  u.password         = "Mod123"
  u.password_confirm = "Mod123"
  u.role             = :moderator
end
moderator.update_column(:role, User.roles[:moderator]) unless moderator.moderator?
puts "  Moderator: #{moderator.email} (id=#{moderator.id}, role=#{moderator.role})"

# 一般ユーザー 50人
experiences = Constants::VALID_EXPERIENCE_OPTIONS
50.times do |n|
  User.find_or_create_by!(email: "user#{n + 1}@example.com") do |u|
    u.name             = Faker::Name.name
    u.password         = "Test1a"
    u.password_confirm = "Test1a"
    u.experience       = experiences.sample
  end
end
puts "  Users: #{User.count} 人"

# フォロー関係
users = User.all.to_a
users.each do |user|
  targets = (users - [user]).sample(rand(0..10))
  targets.each do |target|
    Relationship.find_or_create_by!(follower_id: user.id, followed_id: target.id)
  end
end
puts "  Relationships: #{Relationship.count} 件"

# 投稿
addresses = [
  "神奈川県横浜市中区山下町２７９",
  "大阪府大阪市旭区太子橋２丁目７−８",
  "神奈川県藤沢市鵠沼海岸１丁目１７−３",
  "東京都世田谷区駒沢公園１−１",
  "東京都墨田区亀沢１丁目１−１１",
  "大阪府大阪市鶴見区緑地公園",
  "東京都北区十条仲原４丁目２−１",
  "大阪府守口市松下町１−８０ 大枝公園パークセンタ",
  "愛知県名古屋市東区東桜１丁目１１−１",
  "大阪府大阪市中央区大阪城１−１",
  "大阪府吹田市千里万博公園",
  "大阪府大阪市北区扇町１丁目１",
  "東京都世田谷区代田４丁目３８−５２",
  "東京都世田谷区代田４丁目３８−５２",
  "群馬県前橋市大手町三丁目15",
  "愛知県弥富市鳥ケ地町二反田１２３８",
  "大阪府泉佐野市りんくう往来北１−２７１",
  "大阪府豊中市服部緑地１丁目１",
  "兵庫県尼崎市長洲西通１丁目１３−７",
  "愛知県大府市森岡町９丁目３００",
  "東京都千代田区神田和泉町１−３００",
  "大阪府大阪市港区海岸通１丁目１",
  "大阪府大阪市港区海岸通１丁目１",
  "兵庫県神戸市中央区波止場町２",
  "東京都多摩市落合２丁目３５",
  "東京都港区台場１丁目４",
  "大阪府大阪市北区中之島１丁目１",
  "兵庫県神戸市中央区脇浜海岸通１丁目４−１",
  "大阪府大阪市鶴見区緑地公園２−２ 自然体験観察園",
  "東京都練馬区光が丘４丁目１−１",
]

post_users = User.where.not(email: Constants::GUEST_EMAIL).to_a
30.times do |n|
  author = post_users.sample
  post = Post.find_or_create_by!(title: "sample-spot#{n + 1}") do |p|
    p.address   = addresses[n]
    p.content   = "これは#{n + 1}番目のスポットの投稿です。"
    p.user      = author
    p.user_name = author.name
  end

  image_path = Rails.root.join("app/assets/images/seeds/spot_image#{n + 1}.jpg")
  if image_path.exist? && !post.spot_image.attached?
    post.spot_image.attach(io: File.open(image_path), filename: "spot_image#{n + 1}.jpg")
  end

  print "\r  Posts: #{n + 1}/30"
end
puts "\n  Posts: #{Post.count} 件"

# いいね
posts = Post.all.to_a
users.each do |user|
  posts.sample(rand(0..10)).each do |post|
    Like.find_or_create_by!(user_id: user.id, post_id: post.id)
  end
end
puts "  Likes: #{Like.count} 件"

puts "=== Seeding complete ==="
