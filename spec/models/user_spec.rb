# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :username }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of :email }
    it { should_not allow_value('test@test').for(:email).with_message('invalid format') }
    it { should allow_value('user@example.com').for(:email) }
    it { is_expected.to validate_presence_of :password }
    it { should validate_confirmation_of(:password) }
    it {
      is_expected.to validate_length_of(:password).is_at_least(8)
                                                  .with_message('should be more than 7 chars')
    }
    it {
      is_expected.to validate_length_of(:password).is_at_most(16)
                                                  .with_message('should be less than 17 chars')
    }
  end

  describe 'associations' do
    it { is_expected.to have_many(:courses).with_foreign_key(:author_id) }
  end
end
