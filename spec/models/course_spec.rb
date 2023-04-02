# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:author).class_name(:User) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    subject { create(:course, author: user) }

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :path }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:author_id) }
  end
end
