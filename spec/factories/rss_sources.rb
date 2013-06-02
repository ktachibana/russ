# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rss_source do
    user
    url "http://test.com/rss.xml"
    title "title"
    link_url "http://test.com/content"
    describe "description"
  end
end
