# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    feed
    title "item title"
    sequence(:link) {|n| "http://test.com/content/#{n}" }
    published_at { Time.now }
    description "item description"
  end
end
