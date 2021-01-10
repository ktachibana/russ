# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "mail#{n}@example.com" }
    sequence(:password) { |n| "password#{n}" }
  end
end
