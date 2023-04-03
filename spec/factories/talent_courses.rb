# frozen_string_literal: true

FactoryBot.define do
  factory :talent_course do
    status { 'Not_started_yet' }
    finished_at { nil }
  end
end
