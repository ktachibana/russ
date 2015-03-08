# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription do
    user
    feed
    title nil

    trait :with_title do
      sequence(:title) { |n| "Title #{n}" }
    end
  end
end
