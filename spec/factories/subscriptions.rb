# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :subscription do
    user
    feed
    title nil

    transient do
      item_count 0
    end

    after :create do |subscription, evaluator|
      create_list(:item, evaluator.item_count, feed: subscription.feed)
    end

    trait :with_title do
      sequence(:title) { |n| "Title #{n}" }
    end
  end
end
