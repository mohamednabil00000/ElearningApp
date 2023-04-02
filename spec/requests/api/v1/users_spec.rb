# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::UsersController, type: :request do
  describe '#create' do
    context 'return success' do
      it 'when user created successfully' do
        expect do
          post '/api/v1/users',
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
          post '/api/v1/users',
               params: { user: { email: user.email, password: '12345678', password_confirmation: '12345678',
                                 username: 'test' } }
        end.not_to change(User, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Email has already been taken'
      end

      it 'when the password confirmation does not exist' do
        expect do
          post '/api/v1/users', params: { user: { email: 'test@test.com', password: '12345678', username: 'test' } }
        end.not_to change(User, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly "Password confirmation can't be blank"
      end

      it 'when the password confirmation does not match' do
        expect do
          post '/api/v1/users',
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
        get "/api/v1/users/#{user.id}"
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
        get "/api/v1/users/#{user.id + 1}"
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'User is not found!'
      end
    end
  end

  describe '#update' do
    let!(:user) { create(:user) }

    context 'return success' do
      it 'when doing full update' do
        expect do
          put "/api/v1/users/#{user.id}",
              params: { user: { email: 'test@gmail.com', password: '12345678', password_confirmation: '12345678',
                                username: 'test' } }
        end.not_to change(User, :count)
        expect(response.status).to eq 204
        updated_user = User.find_by(id: user.id)
        expect(updated_user.email).to eq 'test@gmail.com'
        expect(updated_user.username).to eq 'test'
      end

      it 'when doing partial update' do
        expect do
          patch "/api/v1/users/#{user.id}",
                params: { user: { email: 'test2@gmail.com', username: 'test2' } }
        end.not_to change(User, :count)
        expect(response.status).to eq 204
        updated_user = User.find_by(id: user.id)
        expect(updated_user.email).to eq 'test2@gmail.com'
        expect(updated_user.username).to eq 'test2'
      end

      it 'when doing update for single attribure' do
        expect do
          patch "/api/v1/users/#{user.id}",
                params: { user: { email: 'test3@gmail.com' } }
        end.not_to change(User, :count)
        expect(response.status).to eq 204
        updated_user = User.find_by(id: user.id)
        expect(updated_user.email).to eq 'test3@gmail.com'
        expect(updated_user.username).to eq user.username
      end
    end

    context 'return failure' do
      it 'when the password exist without confirmation password' do
        put "/api/v1/users/#{user.id}",
            params: { user: { email: 'test@gmail.com', password: '12345678',
                              username: 'test' } }
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly "Password confirmation can't be blank"
      end

      it 'when user does not exist' do
        put "/api/v1/users/#{user.id + 1}",
            params: { user: { email: 'test@gmail.com', password: '12345678',
                              username: 'test' } }
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'User is not found!'
      end

      it 'when the password does not match the confirmation password' do
        put "/api/v1/users/#{user.id}",
            params: { user: { email: 'test@gmail.com', password: '12345678', password_confirmation: '12345',
                              username: 'test' } }
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly "Password confirmation doesn't match Password"
      end

      it 'when the email is invalid format' do
        put "/api/v1/users/#{user.id}",
            params: { user: { email: 'test@gmail.c', password: '12345678', password_confirmation: '12345678',
                              username: 'test' } }
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Email invalid format'
      end
    end
  end

  describe '#index' do
    context 'return success' do
      it 'when return users successfully' do
        user1 = create(:user)
        user2 = create(:user)

        get '/api/v1/users'
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to match_array([
                                                           {
                                                             'id' => user1.id,
                                                             'username' => user1.username,
                                                             'email' => user1.email
                                                           },
                                                           {
                                                             'id' => user2.id,
                                                             'username' => user2.username,
                                                             'email' => user2.email
                                                           }
                                                         ])
      end

      it 'when return empty' do
        get '/api/v1/users'
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq []
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
            delete "/api/v1/users/#{author.id}", params: { transfer_to: author2.id }
            expect(response.status).to eq 204
            course.reload
            expect(course.author_id).to eq author2.id
          end.to change(User, :count).by(-1)
        end
      end
      context 'return failure' do
        it 'when transfer to parameter is missed' do
          expect do
            delete "/api/v1/users/#{author.id}"
          end.not_to change(User, :count)

          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['errors'])
            .to contain_exactly I18n.t('errors.messages.this_user_is_author_for_some_courses')
        end

        it 'when transfer to does not exist' do
          expect do
            delete "/api/v1/users/#{author.id}", params: { transfer_to: '123456' }
          end.not_to change(User, :count)

          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['errors']).to contain_exactly 'Alternate_auther is not found!'
        end

        it 'when transfer to is equal to the original author' do
          expect do
            delete "/api/v1/users/#{author.id}", params: { transfer_to: author.id }
          end.not_to change(User, :count)

          expect(response.status).to eq 400
          expect(JSON.parse(response.body)['errors'])
            .to contain_exactly I18n.t('errors.messages.alternate_author_should_not_be_original_author')
        end
      end
    end

    context 'when the user is not an author' do
      context 'return success' do
        let!(:user) { create(:user) }
        it 'author deleted successfuly' do
          expect do
            delete "/api/v1/users/#{user.id}"
            expect(response.status).to eq 204
          end.to change(User, :count).by(-1)
        end
      end
      context 'return failure' do
        it 'when user does not exist' do
          expect do
            delete '/api/v1/users/12345'
          end.not_to change(User, :count)

          expect(response.status).to eq 404
          expect(JSON.parse(response.body)['errors']).to contain_exactly 'User is not found!'
        end
      end
    end
  end
end
