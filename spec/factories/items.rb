# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :item do
    feed
    sequence(:title) { |n| "item title#{n}" }
    sequence(:link) { |n| "http://test.com/content/#{n}" }
    published_at { Time.current }
    sequence(:description) { |n| "item description#{n}" }
  end
end
