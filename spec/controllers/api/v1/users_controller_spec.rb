# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::UsersController, type: :controller do
  describe '#create' do
    context 'return success' do
      it 'when user created successfully' do
        expect do
          post :create,
               params: { user: { email: 'test@gmail.com', password: '12345678', password_confirmation: '12345678',
                                 username: 'test' } }
        end.to change(User, :count).by(1)
        expect(response.status).to eq 201
        user = User.last
        expected_response = {
          'email' => user.email,
          'id' => user.id,
          'username' => user.username
        }
        expect(JSON.parse(response.body)).to eq expected_response
      end
    end

    context 'return failures' do
      it 'when the user exists before' do
        user = create :user, email: 'test@test.com'
        expect do
          post :create,
               params: { user: { email: user.email, password: '12345678', password_confirmation: '12345678',
                                 username: 'test' } }
        end.not_to change(User, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Email has already been taken'
      end

      it 'when the password confirmation does not exist' do
        expect do
          post :create, params: { user: { email: 'test@test.com', password: '12345678', username: 'test' } }
        end.not_to change(User, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly "Password confirmation can't be blank"
      end

      it 'when the password confirmation does not match' do
        expect do
          post :create,
               params: { user: { email: 'test@test.com', password: '12345678', username: 'test',
                                 password_confirmation: '123456789' } }
        end.not_to change(User, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly "Password confirmation doesn't match Password"
      end
    end
  end

  describe '#show' do
    let!(:user) { create(:user) }

    context 'return success' do
      it 'return user json object' do
        get :show, params: { id: user.id }
        expect(response.status).to eq 200
        expected_response = {
          'email' => user.email,
          'id' => user.id,
          'username' => user.username
        }
        expect(JSON.parse(response.body)).to eq expected_response
      end
    end

    context 'return failure' do
      it 'expect 404 when the user does not exist' do
        get :show, params: { id: user.id + 1 }
        expect(response.status).to eq 404
      end
    end
  end

  describe '#update' do
    let!(:user) { create(:user) }

    context 'return success' do
      it 'when doing full update' do
        expect do
          put :update,
              params: { user: { email: 'test@gmail.com', password: '12345678', password_confirmation: '12345678',
                                username: 'test' }, id: user.id }
        end.not_to change(User, :count)
        expect(response.status).to eq 204
        updated_user = User.find_by(id: user.id)
        expect(updated_user.email).to eq 'test@gmail.com'
        expect(updated_user.username).to eq 'test'
      end

      it 'when doing partial update' do
        expect do
          patch :update,
                params: { user: { email: 'test2@gmail.com', username: 'test2' }, id: user.id }
        end.not_to change(User, :count)
        expect(response.status).to eq 204
        updated_user = User.find_by(id: user.id)
        expect(updated_user.email).to eq 'test2@gmail.com'
        expect(updated_user.username).to eq 'test2'
      end

      it 'when doing update for single attribure' do
        expect do
          patch :update,
                params: { user: { email: 'test3@gmail.com' }, id: user.id }
        end.not_to change(User, :count)
        expect(response.status).to eq 204
        updated_user = User.find_by(id: user.id)
        expect(updated_user.email).to eq 'test3@gmail.com'
        expect(updated_user.username).to eq user.username
      end
    end

    context 'return failure' do
      it 'when the password exist without confirmation password' do
        put :update,
            params: { user: { email: 'test@gmail.com', password: '12345678',
                              username: 'test' }, id: user.id }
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly "Password confirmation can't be blank"
      end

      it 'when the password does not match the confirmation password' do
        put :update,
            params: { user: { email: 'test@gmail.com', password: '12345678', password_confirmation: '12345',
                              username: 'test' }, id: user.id }
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly "Password confirmation doesn't match Password"
      end

      it 'when the email is invalid format' do
        put :update,
            params: { user: { email: 'test@gmail.c', password: '12345678', password_confirmation: '12345678',
                              username: 'test' }, id: user.id }
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Email invalid format'
      end
    end
  end
end
