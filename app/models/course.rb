# frozen_string_literal: true

class Course < ApplicationRecord
  belongs_to :author, class_name: :User
  has_many :talent_courses, dependent: :delete_all
  has_many :talents, through: :talent_courses, class_name: :User
  has_many :learning_path_courses, dependent: :delete_all
  has_many :learning_paths, through: :learning_path_courses

  validates :path, presence: true
  validates :name, presence: true, uniqueness: { scope: :author_id }
end
