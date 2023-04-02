# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    name { Faker::ProgrammingLanguage.name }
    path { '/path1' }
  end
end
