# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LearningPath, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:author).class_name(:User) }
    it { is_expected.to have_many(:courses).through(:learning_path_courses) }
    it { is_expected.to have_many(:learning_path_courses).dependent(:delete_all) }
    it { is_expected.to have_many(:talents).through(:talent_learning_paths).class_name(:User) }
    it { is_expected.to have_many(:talent_learning_paths).dependent(:delete_all) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:course) { create(:course, author: user) }
    subject { create(:learning_path, author: user, course_ids: [course.id]) }

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:author_id) }
  end
end
