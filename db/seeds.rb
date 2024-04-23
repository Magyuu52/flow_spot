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

50.times do |n|
  title = "sample-spot#{n + 1}"
  address = Faker::Address.full_address
  content = "これは#{n + 1}番目のスポットの投稿です。"
  user_id = Faker::Number.between(from: 1, to: 50)

  post = Post.create!(
    title: title,
    address: address,
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
