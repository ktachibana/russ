# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :feed do
    sequence(:url) { |n| "http://test.com/rss#{n}.xml" }
    sequence(:title) { |n| "Feed id:#{n}" }
    sequence(:link_url) { |n| "http://test.com/content#{n}" }
    sequence(:description) { |n| "description#{n}" }

    ignore do
      item_count 0
    end

    after :create do |feed, evaluator|
      create_list(:item, evaluator.item_count, feed: feed)
    end
  end
end
