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
  end

  describe '#destroy' do
    context 'when the user is an author' do
      let!(:author) { create(:user) }
      let!(:course) { create(:course, author: author) }

      context 'return success' do
        let!(:author2) { create(:user) }

        it 'author deleted successfuly' do
          expect do
            params = { transfer_to: author2.id }
            result = subject.destroy(user: author, params: params)
            expect(result).to be_successful
            course.reload
            expect(course.author_id).to eq author2.id
          end.to change(User, :count).by(-1)
        end
      end
      context 'return failure' do
        it 'when transfer to parameter is missed' do
          expect do
            result = subject.destroy(user: author, params: {})
            expect(result).not_to be_successful
            expect(result.attributes[:errors])
              .to contain_exactly(I18n.t('errors.messages.this_user_is_author_for_some_courses'))
          end.not_to change(User, :count)
        end
      end
    end

    context 'when the user is not an author' do
      context 'return success' do
        let!(:user) { create(:user) }
        it 'author deleted successfuly' do
          expect do
            result = subject.destroy(user: user, params: {})
            expect(result).to be_successful
          end.to change(User, :count).by(-1)
        end
      end
    end
  end
end
