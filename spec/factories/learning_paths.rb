# frozen_string_literal: true

FactoryBot.define do
  factory :learning_path do
    name { Faker::Internet.username }
  end
end
