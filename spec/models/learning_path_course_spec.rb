# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LearningPathCourse, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:learning_path) }
    it { is_expected.to belong_to(:course) }
  end

  describe 'validations' do
    it do
      author = create :user
      course = create :course, author_id: author.id
      course2 = create :course, author_id: author.id
      learning_path = create :learning_path, author_id: author.id, course_ids: [course.id]

      create(:learning_path_course, course_id: course2.id, learning_path_id: learning_path.id)
      is_expected.to validate_uniqueness_of(:course_id)
        .scoped_to(:learning_path_id)
    end
  end
end
