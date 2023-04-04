# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::LearningPathsController, type: :request do
  let(:author) { create(:user) }
  let(:author2) { create(:user) }
  let(:course1) { create(:course, author_id: author.id) }
  let(:course2) { create(:course, author_id: author.id) }

  describe '#create' do
    context 'return success' do
      it 'when the learning path record created successfully' do
        expect do
          post '/api/v1/learning_paths', params: { learning_path: {
            name: 'learning_path1', author_id: author.id, course_ids: [course1.id, course2.id]
          } }
        end.to change(LearningPath, :count).by(1)
        expect(response.status).to eq 201
        learning_path = LearningPath.last
        expected_response = {
          'id' => learning_path.id,
          'name' => learning_path.name,
          'author' => {
            'id' => author.id,
            'username' => author.username,
            'email' => author.email
          },
          'courses' => [
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
                'id' => author.id,
                'username' => author.username,
                'email' => author.email
              }
            }
          ]
        }
        expect(JSON.parse(response.body)).to eq expected_response
      end

      it 'when we have two learning paths with same name but diff authors' do
        create :learning_path, name: 'learning_path1', author_id: author.id, course_ids: [course1.id]
        expect do
          post '/api/v1/learning_paths', params: { learning_path: {
            name: 'learning_path1', author_id: author2.id, course_ids: [course1.id, course2.id]
          } }
        end.to change(LearningPath, :count).by(1)
        expect(response.status).to eq 201
      end

      it 'when we have same course twice in courses parameter' do
        expect do
          post '/api/v1/learning_paths', params: { learning_path: {
            name: 'learning_path1', author_id: author.id, course_ids: [course1.id, course1.id]
          } }
        end.to change(LearningPath, :count).by(1)
        expect(response.status).to eq 201
        learning_path = LearningPath.last
        expected_response = {
          'id' => learning_path.id,
          'name' => learning_path.name,
          'author' => {
            'id' => author.id,
            'username' => author.username,
            'email' => author.email
          },
          'courses' => [
            {
              'path' => course1.path,
              'id' => course1.id,
              'name' => course1.name,
              'author' => {
                'id' => author.id,
                'username' => author.username,
                'email' => author.email
              }
            }
          ]
        }
        expect(JSON.parse(response.body)).to eq expected_response
      end
    end

    context 'return failure' do
      it 'when the learning path does not contain courses' do
        expect do
          post '/api/v1/learning_paths', params: { learning_path: {
            name: 'learning_path1', author_id: author.id, course_ids: []
          } }
        end.not_to change(LearningPath, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors'])
          .to contain_exactly 'Learning path should at least contain one course!'
      end

      it 'when we add non-exist course among course_ids' do
        expect do
          post '/api/v1/learning_paths', params: { learning_path: {
            name: 'learning_path1', author_id: author.id, course_ids: [course1.id, 12_345]
          } }
        end.not_to change(LearningPath, :count)
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors'])
          .to contain_exactly "Couldn't find all Courses with 'id': " \
                              "(#{course1.id}, 12345) (found 1 results, but was looking for 2). " \
                              "Couldn't find Course with id 12345."
      end

      it 'when course_ids parameter is missed' do
        expect do
          post '/api/v1/learning_paths', params: { learning_path: {
            name: 'learning_path1', author_id: author.id
          } }
        end.not_to change(LearningPath, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors'])
          .to contain_exactly 'Learning path should at least contain one course!'
      end

      it 'when learning path name is duplicate in scope of author' do
        create :learning_path, name: 'learning_path1', author_id: author.id, course_ids: [course1.id]
        expect do
          post '/api/v1/learning_paths', params: { learning_path: {
            name: 'learning_path1', author_id: author.id, course_ids: [course1.id, course2.id]
          } }
        end.not_to change(LearningPath, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Name has already been taken'
      end

      it 'when name parameter is missed' do
        expect do
          post '/api/v1/learning_paths', params: { learning_path: {
            author_id: author.id, course_ids: [course1.id]
          } }
        end.not_to change(LearningPath, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly "Name can't be blank"
      end

      it 'when author is missed' do
        expect do
          post '/api/v1/learning_paths', params: { learning_path: {
            name: 'learning_path1', course_ids: [course1.id]
          } }
        end.not_to change(LearningPath, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Author must exist'
      end

      it 'when author does not exist' do
        expect do
          post '/api/v1/learning_paths', params: { learning_path: {
            name: 'learning_path1', author_id: 12_345, course_ids: [course1.id]
          } }
        end.not_to change(LearningPath, :count)
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Author must exist'
      end
    end
  end

  describe '#destroy' do
    let!(:learning_path) do
      create :learning_path, name: 'learning_path1', author_id: author.id, course_ids: [course1.id, course2.id]
    end
    context 'return success' do
      it 'when the learning path deleted successfully' do
        delete "/api/v1/learning_paths/#{learning_path.id}"

        expect(response.status).to eq 204
        expect(LearningPath.find_by(id: learning_path.id)).to eq nil
      end
    end

    context 'return failure' do
      it 'when the learning path does not exist' do
        delete '/api/v1/learning_paths/12345'
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Learning_path is not found!'
      end
    end
  end

  describe '#index' do
    context 'return success' do
      it 'when return learning paths successfully' do
        learning_path1 = create :learning_path, name: 'learning_path1', author_id: author.id,
                                                course_ids: [course1.id, course2.id]
        learning_path2 = create :learning_path, name: 'learning_path2', author_id: author.id,
                                                course_ids: [course2.id, course1.id]

        get '/api/v1/learning_paths'
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to match_array([
                                                           {
                                                             'id' => learning_path1.id,
                                                             'name' => learning_path1.name,
                                                             'author' => {
                                                               'id' => author.id,
                                                               'username' => author.username,
                                                               'email' => author.email
                                                             },
                                                             'courses' => [
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
                                                                   'id' => author.id,
                                                                   'username' => author.username,
                                                                   'email' => author.email
                                                                 }
                                                               }
                                                             ]
                                                           },
                                                           {
                                                             'id' => learning_path2.id,
                                                             'name' => learning_path2.name,
                                                             'author' => {
                                                               'id' => author.id,
                                                               'username' => author.username,
                                                               'email' => author.email
                                                             },
                                                             'courses' => [
                                                               {
                                                                 'path' => course2.path,
                                                                 'id' => course2.id,
                                                                 'name' => course2.name,
                                                                 'author' => {
                                                                   'id' => author.id,
                                                                   'username' => author.username,
                                                                   'email' => author.email
                                                                 }
                                                               },
                                                               {
                                                                 'path' => course1.path,
                                                                 'id' => course1.id,
                                                                 'name' => course1.name,
                                                                 'author' => {
                                                                   'id' => author.id,
                                                                   'username' => author.username,
                                                                   'email' => author.email
                                                                 }
                                                               }
                                                             ]
                                                           }
                                                         ])
      end

      it 'when return empty' do
        get '/api/v1/learning_paths'
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to eq []
      end
    end
  end

  describe '#update' do
    let!(:learning_path) do
      create :learning_path, name: 'learning_path1', author_id: author.id, course_ids: [course1.id, course2.id]
    end
    context 'return success' do
      it 'when we update the order of courses, name and the author' do
        put "/api/v1/learning_paths/#{learning_path.id}", params: { learning_path: {
          name: 'learning_path2', author_id: author2.id, course_ids: [course2.id, course1.id]
        } }
        expect(response.status).to eq 204
        learning_path.reload
        expect(learning_path.name).to eq 'learning_path2'
        expect(learning_path.author_id).to eq author2.id
        expect(LearningPathCourse.where(learning_path_id: learning_path.id).pluck(:course_id)).to eq [course2.id,
                                                                                                      course1.id]
      end
    end

    context 'return failure' do
      it 'when we update the courses by adding non-exist course' do
        put "/api/v1/learning_paths/#{learning_path.id}", params: { learning_path: {
          name: 'learning_path2', author_id: author2.id, course_ids: [course2.id, 12_345]
        } }

        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors'])
          .to contain_exactly "Couldn't find all Courses with 'id': " \
                              "(#{course2.id}, 12345) (found 1 results, but was looking for 2). " \
                              "Couldn't find Course with id 12345."
      end

      it 'when we update the author by adding non-exist author' do
        put "/api/v1/learning_paths/#{learning_path.id}", params: { learning_path: {
          name: 'learning_path2', author_id: 12_345
        } }

        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Author must exist'
      end

      it 'when we update the name to be like another exist one' do
        create :learning_path, name: 'learning_path2', author_id: author.id, course_ids: [course1.id, course2.id]
        put "/api/v1/learning_paths/#{learning_path.id}", params: { learning_path: {
          name: 'learning_path2', author_id: author.id
        } }

        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Name has already been taken'
      end
    end
  end
end
