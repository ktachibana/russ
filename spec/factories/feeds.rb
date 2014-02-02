# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :feed do
    sequence(:url) { |n| "http://test.com/rss#{n}.xml" }
    sequence(:title) { |n| "Feed id:#{n}" }
    sequence(:link_url) { |n| "http://test.com/content#{n}" }
    sequence(:description) { |n| "description#{n}" }
  end
end
