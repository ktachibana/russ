# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :feed do
    sequence(:url) { |n| "http://test.com/rss#{n}.xml" }
    sequence(:title) { |n| "Feed id:#{n}" }
    sequence(:link_url) { |n| "http://test.com/content#{n}" }
    sequence(:description) { |n| "description#{n}" }

    transient do
      item_count { 0 }
    end

    after :create do |feed, evaluator|
      create_list(:item, evaluator.item_count, feed: feed)
    end
  end

  factory :feed_only_url, class: Feed do
    sequence(:url) { |n| "http://test.com/rss#{n}.xml" }
  end
end
