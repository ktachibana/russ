# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email){|n| "mail#{n}@example.com" }
    password 'password'
  end
end
