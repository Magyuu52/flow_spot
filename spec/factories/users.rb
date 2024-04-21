FactoryBot.define do
  factory :user do
    name { 'test_user' }
    email { Faker::Internet.email }
    password { 'Test123' }
    password_confirm { 'Test123' }
  end
end