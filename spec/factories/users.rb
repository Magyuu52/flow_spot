FactoryBot.define do
  factory :user do
    name { 'test_user' }
    email { Faker::Internet.email }
    password { 'Test123' }
    password_confirm { 'Test123' }
    role { :general }

    trait :moderator do
      role { :moderator }
    end

    trait :admin do
      role { :admin }
    end

    trait :guest do
      name { Constants::GUEST_NAME }
      email { Constants::GUEST_EMAIL }
    end
  end
end