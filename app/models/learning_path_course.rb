# frozen_string_literal: true

class LearningPathCourse < ApplicationRecord
  belongs_to :course
  belongs_to :learning_path

  validates_uniqueness_of :course_id, scope: :learning_path_id
end
