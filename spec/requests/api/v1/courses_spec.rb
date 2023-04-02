# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::CoursesController, type: :request do
  let(:author) { create(:user) }

  describe '#create' do
    context 'return success' do
      it 'when the course created successfully' do
        expect do
          post '/api/v1/courses',
               params: { course: { name: 'course1', author_id: author.id,
                                   path: '/path1' } }
        end.to change(Course, :count).by(1)
        expect(response.status).to eq 201
        course = Course.last
        expected_response = {
          'path' => course.path,
          'id' => course.id,
          'name' => course.name,
          'author' => {
            'id' => author.id,
            'username' => author.username,
            'email' => author.email
          }
        }
        expect(JSON.parse(response.body)).to eq expected_response
      end

      it 'when we have two same courses but diff authors' do
        create :course, name: 'course1', author_id: author.id
        author2 = create :user
        expect do
          post '/api/v1/courses',
               params: { course: { name: 'course1', author_id: author2.id,
                                   path: '/path1' } }
        end.to change(Course, :count).by(1)
        expect(response.status).to eq 201
        course = Course.last
        expected_response = {
          'path' => course.path,
          'id' => course.id,
          'name' => course.name,
          'author' => {
            'id' => author2.id,
            'username' => author2.username,
            'email' => author2.email
          }
        }
        expect(JSON.parse(response.body)).to eq expected_response
      end
    end

    context 'return failures' do
      it 'when the course exists before with the same author' do
        create :course, name: 'course1', author_id: author.id
        expect do
          post '/api/v1/courses',
               params: { course: { name: 'course1', author_id: author.id,
                                   path: '/path1' } }
        end.not_to change(Course, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Name has already been taken'
      end

      it 'when the author does not exist' do
        expect do
          post '/api/v1/courses', params: { course: { name: 'course1', path: '/path1' } }
        end.not_to change(Course, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Author must exist'
      end
    end
  end

  describe '#show' do
    let!(:course) { create(:course, author: author) }

    context 'return success' do
      it 'return course json object' do
        get "/api/v1/courses/#{course.id}"
        expect(response.status).to eq 200
        expected_response = {
          'path' => course.path,
          'id' => course.id,
          'name' => course.name,
          'author' => {
            'id' => author.id,
            'username' => author.username,
            'email' => author.email
          }
        }
        expect(JSON.parse(response.body)).to eq expected_response
      end
    end

    context 'return failure' do
      it 'expect 404 when the user does not exist' do
        get "/api/v1/courses/#{course.id + 1}"
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Course is not found!'
      end
    end
  end

  describe '#update' do
    let!(:author2) { create(:user) }
    let!(:course) { create(:course, author: author) }

    context 'return success' do
      it 'when doing full update' do
        expect do
          put "/api/v1/courses/#{course.id}",
              params: { course: { name: 'course1', author_id: author2.id,
                                  path: '/path1' } }
        end.not_to change(Course, :count)
        expect(response.status).to eq 204
        updated_course = Course.find_by(id: course.id)
        expect(updated_course.name).to eq 'course1'
        expect(updated_course.path).to eq '/path1'
        expect(updated_course.author_id).to eq author2.id
      end

      it 'when doing partial update' do
        expect do
          patch "/api/v1/courses/#{course.id}",
                params: { course: { name: 'course1', path: '/path1' } }
        end.not_to change(Course, :count)
        expect(response.status).to eq 204
        updated_course = Course.find_by(id: course.id)
        expect(updated_course.name).to eq 'course1'
        expect(updated_course.path).to eq '/path1'
        expect(updated_course.author_id).to eq author.id
      end

      it 'when update the name to exist one but for another author' do
        create :course, name: 'course2', author_id: author2.id
        expect do
          patch "/api/v1/courses/#{course.id}",
                params: { course: { name: 'course2' } }
        end.not_to change(Course, :count)
        expect(response.status).to eq 204
        updated_course = Course.find_by(id: course.id)
        expect(updated_course.name).to eq 'course2'
        expect(updated_course.path).to eq course.path
        expect(updated_course.author_id).to eq author.id
      end
    end

    context 'return failure' do
      it 'when update name to exist one before with the same author' do
        create :course, name: 'course2', author_id: author.id
        patch "/api/v1/courses/#{course.id}", params: { course: { name: 'course2' } }
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Name has already been taken'
      end

      it 'when course does not exist' do
        patch "/api/v1/courses/#{course.id + 1}", params: { course: { name: 'course2' } }
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Course is not found!'
      end

      it 'when the updated author does not exist' do
        patch "/api/v1/courses/#{course.id}", params: { course: { author_id: 123_456 } }
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Author must exist'
      end
    end
  end

  describe '#destroy' do
    let!(:course) { create(:course, author: author) }
    context 'return success' do
      it 'when the course deleted successfully' do
        delete "/api/v1/courses/#{course.id}"

        expect(response.status).to eq 204
      end
    end

    context 'return failure' do
      it 'when the course does not exist' do
        delete "/api/v1/courses/#{course.id + 1}"
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Course is not found!'
      end
    end
  end

  describe '#index' do
    context 'return success' do
      it 'when return courses successfully' do
        author2 = create(:user)
        course1 = create(:course, author: author)
        course2 = create(:course, author: author2)

        get '/api/v1/courses'
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to match_array([
                                                           {
                                                             'path' => course1.path,
                                                             'id' => course1.id,
                                                             'name' => course1.name,
                                                             'author' => {
                                                               'id' => author.id,
                                                               'username' => author.username,
                                                               'email' => author.email
                                                             }
                                                           },
                                                           {
                                                             'path' => course2.path,
                                                             'id' => course2.id,
                                                             'name' => course2.name,
                                                             'author' => {
                                                               'id' => author2.id,
                                                               'username' => author2.username,
                                                               'email' => author2.email
                                                             }
                                                           }
                                                         ])
      end

      it 'when return empty' do
        get '/api/v1/courses'
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq []
      end
    end
  end
end
