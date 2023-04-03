# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TalentCourse, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:talent).class_name(:User) }
    it { is_expected.to belong_to(:course) }
  end

  describe 'validations' do
    it do
      author = create :user
      talent = create :user
      course = create :course, author_id: author.id
      create(:talent_course, course_id: course.id, talent_id: talent.id)
      is_expected.to validate_uniqueness_of(:course_id)
        .scoped_to(:talent_id)
        .with_message(I18n.t('errors.messages.course_already_taken_by_this_user'))
    end
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[Not_started_yet In_progress Completed]) }
  end
end
