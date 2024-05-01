ActiveStorage::AnalyzeJob.queue_adapter = :inline
ActiveStorage::PurgeJob.queue_adapter = :inline
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
50.times do |n|
  name = Faker::Name.name
  email = Faker::Internet.email
  password = Faker::Internet.password(min_length: 6, max_length: 12)

  User.create(
    name: name,
    email: email,
    password: password,
    password_confirm: password
  )
end

users = User.all
users.each do |user|
  following_users = users - [user]
  following_users.shuffle.take(rand(0..50)).each do |following_user|
    Relationship.find_or_create_by!(
      follower_id: user.id,
      followed_id: following_user.id
    )
  end
end

30.times do |n|
  title = "sample-spot#{n + 1}"
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
    "兵庫県神戸市中央区小野浜町２",
    "愛知県名古屋市中区本丸１−１"
  ]
  content = "これは#{n + 1}番目のスポットの投稿です。"
  user_id = Faker::Number.between(from: 1, to: 50)

  post = Post.create!(
    title: title,
    address: addresses[n],
    content: content,
    user_id: user_id,
  )

  post.spot_image.attach(io: File.open(Rails.root.join("app/assets/images/seeds/spot_image#{n + 1}.jpg")),filename: 'spot_image#{n + 1}.jpg')
end

users = User.all
posts = Post.all
users.each do |user|
  liked_posts = posts.sample(rand(0..50))
  liked_posts.each do |post|
    Like.find_or_create_by!(
      user_id: user.id,
      post_id: post.id
    )
  end
end
