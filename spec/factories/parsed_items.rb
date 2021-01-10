# frozen_string_literal: true

FactoryBot.define do
  factory :parsed_item, class: 'OpenStruct' do
    sequence(:link) { |n| "http://parsed-item.com/link/#{n}" }
    sequence(:title) { |n| "Title #{n}" }
    sequence(:date) { |n| n.days.ago }
    sequence(:description) { |n| "description #{n}" }
  end
end
