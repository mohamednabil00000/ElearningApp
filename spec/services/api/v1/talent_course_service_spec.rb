# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TalentCourseService do
  let(:author) { create(:user) }
  let(:course) { create(:course, author_id: author.id) }
  let(:talent) { create(:user) }

  describe '#create' do
    context 'return success' do
      it 'when the course assigned successfully for a given talent' do
        expect do
          result = described_class.new.create(course_id: course.id, talent_id: talent.id)
          expect(result).to be_successful
        end.to change(TalentCourse, :count).by(1)
        talent_course = TalentCourse.last
        expect(talent_course.course_id).to eq course.id
        expect(talent_course.talent_id).to eq talent.id
        expect(talent_course.status).to eq 'Not_started_yet'
        expect(talent_course.finished_at).to eq nil
      end
    end

    context 'return failure' do
      it 'when the same course assigned twice to the same talent' do
        create :talent_course, talent_id: talent.id, course_id: course.id
        expect do
          result = described_class.new.create(course_id: course.id, talent_id: talent.id)
          expect(result).not_to be_successful
          expect(result.attributes[:errors]).to contain_exactly('Course This course is already taken by this user!')
        end.not_to change(TalentCourse, :count)
      end
    end
  end

  describe '#index' do
    context 'return success' do
      let(:course2) { create(:course, author_id: author.id) }

      it 'get all assigned courses successfully' do
        talent_course1 = create :talent_course, talent_id: talent.id, course_id: course.id
        talent_course2 = create :talent_course, talent_id: talent.id, course_id: course2.id

        result = described_class.new.index
        expect(result).to be_successful
        expected_response = [
          {
            id: talent_course1.id,
            status: talent_course1.status,
            finished_at: talent_course1.finished_at,
            course: {
              id: course.id,
              path: course.path,
              name: course.name,
              author: {
                id: author.id,
                email: author.email,
                username: author.username
              }
            },
            talent: {
              id: talent.id,
              email: talent.email,
              username: talent.username
            }
          },
          {
            id: talent_course2.id,
            status: talent_course2.status,
            finished_at: talent_course2.finished_at,
            course: {
              id: course2.id,
              path: course2.path,
              name: course2.name,
              author: {
                id: author.id,
                email: author.email,
                username: author.username
              }
            },
            talent: {
              id: talent.id,
              email: talent.email,
              username: talent.username
            }
          }
        ]

        expect(result.attributes[:talent_courses]).to match_array expected_response
      end

      it 'when the array is empty' do
        result = described_class.new.index
        expect(result).to be_successful
        expect(result.attributes[:talent_courses]).to match_array []
      end
    end
  end

  describe '#destroy' do
    context 'return success' do
      it 'when the record deleted successfully' do
        create :talent_course, talent_id: talent.id, course_id: course.id
        expect do
          result = described_class.new.destroy(course_id: course.id, talent_id: talent.id)
          expect(result).to be_successful
        end.to change(TalentCourse, :count).by(-1)
      end

      it 'when the talent and course does not exist' do
        create :talent_course, talent_id: talent.id, course_id: course.id
        expect do
          result = described_class.new.destroy(course_id: 12_345, talent_id: 12_345)
          expect(result).to be_successful
        end.not_to change(TalentCourse, :count)
      end
    end
  end

  describe '#update' do
    context 'return success' do
      let!(:talent_course) { create :talent_course, talent_id: talent.id, course_id: course.id }
      let(:course2) { create :course, author: author }
      let!(:talent_course2) { create :talent_course, talent_id: talent.id, course_id: course2.id }
      let(:learning_path) { create :learning_path, course_ids: [course.id, course2.id], author_id: author.id }

      it 'when the status updated successfully to in progress' do
        result = described_class.new.update(talent_course: talent_course, params: { status: 'In_progress' })
        expect(result).to be_successful
        talent_course.reload
        expect(talent_course.status).to eq 'In_progress'
        expect(talent_course.finished_at).to eq nil
      end

      it 'when the status updated successfully to completed and talent learning path shift to the next' do
        talent_learning_path = create :talent_learning_path, talent_id: talent.id, learning_path_id: learning_path.id,
                                                             current_talent_course_id: talent_course.id

        result = described_class.new.update(talent_course: talent_course, params: { status: 'Completed' })
        expect(result).to be_successful
        talent_course.reload
        expect(talent_course.status).to eq 'Completed'
        expect(talent_course.finished_at).not_to eq nil
        talent_learning_path.reload
        expect(talent_learning_path.current_talent_course_id).to eq talent_course2.id
      end

      it 'when the params is empty' do
        result = described_class.new.update(talent_course: talent_course, params: {})
        expect(result).to be_successful
        talent_course.reload
        expect(talent_course.status).to eq 'Not_started_yet'
        expect(talent_course.finished_at).to eq nil
      end
    end

    context 'return failure' do
      let!(:talent_course) { create :talent_course, talent_id: talent.id, course_id: course.id }

      it 'when the status does not exist in the list' do
        result = described_class.new.update(talent_course: talent_course, params: { status: 'Done' })
        expect(result).not_to be_successful
        expect(result.attributes[:errors]).to contain_exactly('Status is not included in the list')
      end
    end
  end
end
