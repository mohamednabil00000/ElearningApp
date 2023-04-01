# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UserService do
  let(:subject) { described_class.new }

  describe '#create' do
    context 'return success' do
      let(:params) do
        {
          email: 'test@gmail.com',
          password: '12345678',
          password_confirmation: '12345678',
          username: 'test'
        }
      end

      it 'when user created successfully' do
        result = subject.create(user_params: params)
        expect(result).to be_successful
        expected_res = {
          id: User.first.id,
          username: 'test',
          email: 'test@gmail.com'
        }
        expect(result.attributes[:user]).to eq expected_res
      end
    end

    context 'return failure' do
      it 'when username does not exists' do
        params = {
          email: 'test@gmail.com',
          password: '12345678',
          password_confirmation: '12345678'
        }
        result = described_class.new.create(user_params: params)
        expect(result).not_to be_successful

        expect(result.attributes[:errors]).to match_array(["Username can't be blank"])
      end

      it 'when email does not exists' do
        params = {
          username: 'test',
          password: '12345678',
          password_confirmation: '12345678'
        }
        result = described_class.new.create(user_params: params)
        expect(result).not_to be_successful

        expect(result.attributes[:errors]).to match_array(["Email can't be blank"])
      end

      it 'when password does not exists' do
        params = {
          username: 'test',
          email: 'test@test.com'
        }
        result = described_class.new.create(user_params: params)
        expect(result).not_to be_successful

        expect(result.attributes[:errors]).to match_array(["Password can't be blank"])
      end
    end
  end

  describe '#update' do
    let!(:user) { create(:user) }

    context 'return success' do
      it 'when doing full update' do
        params = {
          email: 'test@gmail.com',
          password: '12345678',
          password_confirmation: '12345678',
          username: 'test'
        }
        result = subject.update(user: user, user_params: params)
        expect(result).to be_successful
      end

      it 'when doing partial update' do
        params = {
          email: 'test@gmail.com',
          username: 'test'
        }
        result = subject.update(user: user, user_params: params)
        expect(result).to be_successful
      end

      it 'when doing single update' do
        params = {
          email: 'test@gmail.com'
        }
        result = subject.update(user: user, user_params: params)
        expect(result).to be_successful
      end
    end

    context 'return failure' do
      it 'when update password without password confirmation' do
        params = {
          password: '12345678'
        }
        result = subject.update(user: user, user_params: params)
        expect(result).not_to be_successful
        expect(result.attributes[:errors]).to contain_exactly("Password confirmation doesn't match Password")
      end

      it 'when user does not exist' do
        params = {
          email: 'test@gmail.com',
          password: '12345678',
          password_confirmation: '12345678',
          username: 'test'
        }
        result = subject.update(user: nil, user_params: params)
        expect(result).not_to be_successful
        expect(result.attributes[:errors]).to contain_exactly('User not found!')
      end

      it 'when update email with invalid format' do
        params = {
          email: 'em@.'
        }
        result = subject.update(user: user, user_params: params)
        expect(result).not_to be_successful
        expect(result.attributes[:errors]).to contain_exactly('Email invalid format')
      end

      it 'when update password but does not match password confirmation' do
        params = {
          password: '12345678',
          password_confirmation: '12345'
        }
        result = subject.update(user: user, user_params: params)
        expect(result).not_to be_successful
        expect(result.attributes[:errors]).to contain_exactly("Password confirmation doesn't match Password")
      end
    end
  end

  describe '#show' do
    let!(:user) { create(:user) }

    context 'return success' do
      it 'when return user successfully' do
        result = subject.show(user: user)
        expect(result).to be_successful
        expected_res = {
          id: user.id,
          username: user.username,
          email: user.email
        }
        expect(result.attributes[:user]).to eq expected_res
      end
    end

    context 'return failure' do
      it 'when user is nil' do
        result = subject.show(user: nil)
        expect(result).not_to be_successful
      end
    end
  end
end
