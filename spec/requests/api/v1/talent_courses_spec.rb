# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TalentCoursesController, type: :request do
  let(:author) { create(:user) }
  let(:course) { create(:course, author_id: author.id) }
  let(:talent) { create(:user) }

  describe '#create' do
    context 'return success' do
      it 'when the course assigned successfully for a given talent' do
        expect do
          post "/api/v1/talents/#{talent.id}/courses/#{course.id}"
          expect(response.status).to eq 200
        end.to change(TalentCourse, :count).by(1)
      end
    end

    context 'return failure' do
      it 'when the talent does not exist' do
        post "/api/v1/talents/123456/courses/#{course.id}"
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'User is not found!'
      end

      it 'when the course does not exist' do
        post "/api/v1/talents/#{talent.id}/courses/123456"
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Course is not found!'
      end

      it 'when the talent and the author are same person' do
        post "/api/v1/talents/#{author.id}/courses/#{course.id}"
        expect(response.status).to eq 400
        expect(JSON.parse(response.body)['errors'])
          .to contain_exactly 'The talent should not be the author of the course!'
      end

      it 'when the same course assigned twice to the same talent' do
        create :talent_course, talent_id: talent.id, course_id: course.id
        post "/api/v1/talents/#{talent.id}/courses/#{course.id}"
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors'])
          .to contain_exactly 'Course This course is already taken by this user!'
      end
    end
  end

  describe '#index' do
    context 'return success' do
      let(:course2) { create(:course, author_id: author.id) }

      it 'get all assigned courses successfully' do
        talent_course1 = create :talent_course, talent_id: talent.id, course_id: course.id
        talent_course2 = create :talent_course, talent_id: talent.id, course_id: course2.id

        get '/api/v1/talent_courses'
        expect(response.status).to eq 200
        expected_response = [
          {
            'id' => talent_course1.id,
            'status' => talent_course1.status,
            'finished_at' => talent_course1.finished_at,
            'course' => {
              'id' => course.id,
              'path' => course.path,
              'name' => course.name,
              'author' => {
                'id' => author.id,
                'email' => author.email,
                'username' => author.username
              }
            },
            'talent' => {
              'id' => talent.id,
              'email' => talent.email,
              'username' => talent.username
            }
          },
          {
            'id' => talent_course2.id,
            'status' => talent_course2.status,
            'finished_at' => talent_course2.finished_at,
            'course' => {
              'id' => course2.id,
              'path' => course2.path,
              'name' => course2.name,
              'author' => {
                'id' => author.id,
                'email' => author.email,
                'username' => author.username
              }
            },
            'talent' => {
              'id' => talent.id,
              'email' => talent.email,
              'username' => talent.username
            }
          }
        ]

        expect(JSON.parse(response.body)['talent_courses']).to match_array expected_response
      end

      it 'when the array is empty' do
        get '/api/v1/talent_courses'
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)['talent_courses']).to match_array []
      end
    end
  end

  describe '#destroy' do
    context 'return success' do
      it 'when the record deleted successfully' do
        create :talent_course, talent_id: talent.id, course_id: course.id
        expect do
          delete "/api/v1/talents/#{talent.id}/courses/#{course.id}"
          expect(response.status).to eq 204
        end.to change(TalentCourse, :count).by(-1)
      end

      it 'when the talent and course does not exist' do
        create :talent_course, talent_id: talent.id, course_id: course.id
        expect do
          delete '/api/v1/talents/123345/courses/123456'
          expect(response.status).to eq 204
        end.not_to change(TalentCourse, :count)
      end
    end
  end

  describe '#update' do
    context 'return success' do
      let!(:talent_course) { create :talent_course, talent_id: talent.id, course_id: course.id }

      it 'when the status updated successfully to in progress' do
        patch "/api/v1/talent_courses/#{talent_course.id}", params: { status: 'In_progress' }
        expect(response.status).to eq 204
        talent_course.reload
        expect(talent_course.status).to eq 'In_progress'
        expect(talent_course.finished_at).to eq nil
      end

      it 'when the status updated successfully to completed' do
        patch "/api/v1/talent_courses/#{talent_course.id}", params: { status: 'Completed' }
        expect(response.status).to eq 204
        talent_course.reload
        expect(talent_course.status).to eq 'Completed'
        expect(talent_course.finished_at).not_to eq nil
      end
    end

    context 'return failure' do
      let!(:talent_course) { create :talent_course, talent_id: talent.id, course_id: course.id }

      it 'when the status does not exist in the list' do
        patch "/api/v1/talent_courses/#{talent_course.id}", params: { status: 'done' }
        expect(response.status).to eq 422
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Status is not included in the list'
      end

      it 'when talent course does' do
        patch '/api/v1/talent_courses/12345', params: { status: 'In_progress' }
        expect(response.status).to eq 404
        expect(JSON.parse(response.body)['errors']).to contain_exactly 'Talent_course is not found!'
      end
    end
  end
end
