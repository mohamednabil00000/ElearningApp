# frozen_string_literal: true

class Course < ApplicationRecord
  belongs_to :author, class_name: :User

  validates :path, presence: true
  validates :name, presence: true, uniqueness: { scope: :author_id }
end
