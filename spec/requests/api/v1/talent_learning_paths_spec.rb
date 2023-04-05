# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TalentLearningPathsController, type: :request do
  let(:author) { create(:user) }
  let(:course1) { create(:course, author_id: author.id) }
  let(:course2) { create(:course, author_id: author.id) }
  let(:talent) { create(:user) }
  let!(:talent_course) { create(:talent_course, course_id: course1.id, talent_id: talent.id) }
  let(:learning_path) do
    create :learning_path, name: 'learning_path1', author_id: author.id, course_ids: [course1.id, course2.id]
  end

  describe '#create' do
    context 'return success' do
      it 'when the talent assigned successfully for a given learning path' do
        expect do
          post "/api/v1/talents/#{talent.id}/learning_paths/#{learning_path.id}"
          expect(response.status).to eq 201
          talent_learning_path = TalentLearningPath.last
          expected_response = {
            'id' => talent_learning_path.id,
            'learning_path' => {
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
            },
            'current_talent_course' => {
              'finished_at' => nil,
              'id' => talent_course.id,
              'status' => 'Not_started_yet',
              'course' => {
                'path' => course1.path,
                'id' => course1.id,
                'name' => course1.name,
                'author' => {
                  'id' => author.id,
                  'username' => author.username,
                  'email' => author.email
                }
              },
              'talent' => {
                'id' => talent.id,
                'username' => talent.username,
                'email' => talent.email
              }
            }
          }
          expect(JSON.parse(response.body)).to eq expected_response
        end.to change(TalentLearningPath, :count).by(1)
      end

      it 'when the talent already completed the first course before assigning it from learning path' do
        talent_course2 = create(:talent_course, course_id: course2.id, talent_id: talent.id)
        talent_course.status = 'Completed'
        talent_course.save

        expect do
          post "/api/v1/talents/#{talent.id}/learning_paths/#{learning_path.id}"
          expect(response.status).to eq 201
          talent_learning_path = TalentLearningPath.last
          expected_response = {
            'id' => talent_learning_path.id,
            'learning_path' => {
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
            },
            'current_talent_course' => {
              'finished_at' => nil,
              'id' => talent_course2.id,
              'status' => 'Not_started_yet',
              'course' => {
                'path' => course2.path,
                'id' => course2.id,
                'name' => course2.name,
                'author' => {
                  'id' => author.id,
                  'username' => author.username,
                  'email' => author.email
                }
              },
              'talent' => {
                'id' => talent.id,
                'username' => talent.username,
                'email' => talent.email
              }
            }
          }
          expect(JSON.parse(response.body)).to eq expected_response
        end.to change(TalentLearningPath, :count).by(1)
      end
    end

    context 'return failure' do
      it 'when the talent does not exist' do
        post "/api/v1/talents/123456/learning_paths/#{learning_path.id}"
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'User is not found!'
      end

      it 'when the learning path does not exist' do
        post "/api/v1/talents/#{talent.id}/learning_paths/123456"
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Learning_path is not found!'
      end

      it 'when the same talent assigned twice to the same learning path' do
        create :talent_learning_path, talent_id: talent.id, learning_path_id: learning_path.id,
                                      current_talent_course_id: talent_course.id
        post "/api/v1/talents/#{talent.id}/learning_paths/#{learning_path.id}"
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors'])
          .to contain_exactly 'Talent already assigned to this learning path!'
      end
    end
  end

  describe '#show' do
    let!(:talent_learning_path) do
      create :talent_learning_path, talent_id: talent.id, learning_path_id: learning_path.id,
                                    current_talent_course_id: talent_course.id
    end

    context 'return success' do
      it 'return talent learning path json object' do
        get "/api/v1/talent_learning_paths/#{talent_learning_path.id}"
        expect(response.status).to eq 200
        expected_response = {
          'id' => talent_learning_path.id,
          'learning_path' => {
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
          },
          'current_talent_course' => {
            'finished_at' => nil,
            'id' => talent_course.id,
            'status' => 'Not_started_yet',
            'course' => {
              'path' => course1.path,
              'id' => course1.id,
              'name' => course1.name,
              'author' => {
                'id' => author.id,
                'username' => author.username,
                'email' => author.email
              }
            },
            'talent' => {
              'id' => talent.id,
              'username' => talent.username,
              'email' => talent.email
            }
          }
        }
        expect(JSON.parse(response.body)).to eq expected_response
      end
    end

    context 'return failure' do
      it 'expect 404 when the user does not exist' do
        get '/api/v1/talent_learning_paths/12345'
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Talent_learning_path is not found!'
      end
    end
  end

  describe '#destroy' do
    context 'return success' do
      it 'when the record deleted successfully' do
        create :talent_learning_path, talent_id: talent.id, learning_path_id: learning_path.id,
                                      current_talent_course_id: talent_course.id
        expect do
          delete "/api/v1/talents/#{talent.id}/learning_paths/#{learning_path.id}"
          expect(response.status).to eq 204
        end.to change(TalentLearningPath, :count).by(-1)
      end

      it 'when the talent and learning path does not exist' do
        expect do
          delete '/api/v1/talents/123345/learning_paths/123456'
          expect(response.status).to eq 204
        end.not_to change(TalentLearningPath, :count)
      end
    end
  end
end
