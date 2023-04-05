# frozen_string_literal: true

class LearningPath < ApplicationRecord
  belongs_to :author, class_name: :User
  has_many :learning_path_courses, dependent: :delete_all
  has_many :courses, through: :learning_path_courses
  has_many :talent_learning_paths, dependent: :delete_all
  has_many :talents, through: :talent_learning_paths, class_name: :User

  validates :name, presence: true, uniqueness: { scope: :author_id }

  before_validation :check_courses_presence?

  private

  def check_courses_presence?
    return unless courses.empty?

    errors.add(:base, I18n.t('errors.messages.Learning_path_should_at_least_contain_one_course'))
    false
  end
end
