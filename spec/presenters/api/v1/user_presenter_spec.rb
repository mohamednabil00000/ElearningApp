# frozen_string_literal: true

require 'spec_helper'

describe Api::V1::UserPresenter do
  let(:user) { create :user }

  describe '#present' do
    it 'return expected user object' do
      expected_json = {
        email: user.email,
        username: user.username,
        id: user.id
      }
      expect(described_class.new.present(user: user)).to eq expected_json
    end

    it 'return nil when user is nil' do
      expect(described_class.new.present(user: nil)).to eq nil
    end
  end

  # TO-DO
  describe '#present_arr' do
  end
end
