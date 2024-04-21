FactoryBot.define do
  factory :post do
    title { 'test-post' }
    address { '大阪府大阪市港区海岸通１丁目１' }
    content { Faker::Lorem.word }
    user

    after(:build) do |post|
      post.spot_image.attach(io: File.open("spec/fixtures/image/test_post.jpg"), filename: "test_post.jpg")
    end
  end
end
