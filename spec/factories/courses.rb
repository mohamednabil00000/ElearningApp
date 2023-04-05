# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    name { Faker::Internet.username }
    path { '/path1' }
  end
end
