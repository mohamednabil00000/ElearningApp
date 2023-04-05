# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TalentLearningPath, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:talent).class_name(:User) }
    it { is_expected.to belong_to(:learning_path) }
    it { is_expected.to belong_to(:current_talent_course).class_name(:TalentCourse) }
  end

  describe 'validations' do
    it do
      author = create(:user)
      talent = create(:user)
      course = create(:course, author_id: author.id)
      talent_course = create(:talent_course, course_id: course.id, talent_id: talent.id)
      learning_path = create(:learning_path, author: author, course_ids: [course.id])
      create(:talent_learning_path, learning_path_id: learning_path.id, talent_id: talent.id,
                                    current_talent_course_id: talent_course.id)

      is_expected.to validate_uniqueness_of(:talent_id)
        .scoped_to(:learning_path_id)
        .with_message(I18n.t('errors.messages.user_already_assigned_to_this_learning_path'))
    end
  end
end
