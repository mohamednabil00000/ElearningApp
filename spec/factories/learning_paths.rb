# frozen_string_literal: true

FactoryBot.define do
  factory :learning_path do
    name { Faker::ProgrammingLanguage.name }
  end
end
