# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TalentLearningPathPresenter do
  let!(:author) { create(:user) }
  let!(:talent) { create(:user) }
  let!(:course1) { create(:course, author_id: author.id, name: 'course1') }
  let!(:course2) { create(:course, author_id: author.id, name: 'course2') }
  let!(:talent_course) { create(:talent_course, course_id: course1.id, talent_id: talent.id) }
  let!(:learning_path) { create(:learning_path, author: author, course_ids: [course1.id, course2.id]) }

  describe '#present' do
    it 'return expected talent learning path object' do
      talent_learning_path = create :talent_learning_path, talent_id: talent.id, learning_path_id: learning_path.id,
                                                           current_talent_course_id: talent_course.id

      expected_response = {
        id: talent_learning_path.id,
        learning_path: {
          id: learning_path.id,
          name: learning_path.name,
          author: {
            id: author.id,
            username: author.username,
            email: author.email
          },
          courses: [
            {
              path: course1.path,
              id: course1.id,
              name: course1.name,
              author: {
                id: author.id,
                username: author.username,
                email: author.email
              }
            },
            {
              path: course2.path,
              id: course2.id,
              name: course2.name,
              author: {
                id: author.id,
                username: author.username,
                email: author.email
              }
            }
          ]
        },
        current_talent_course: {
          finished_at: nil,
          id: talent_course.id,
          status: 'Not_started_yet',
          course: {
            path: course1.path,
            id: course1.id,
            name: course1.name,
            author: {
              id: author.id,
              username: author.username,
              email: author.email
            }
          },
          talent: {
            id: talent.id,
            username: talent.username,
            email: talent.email
          }
        }
      }
      expect(described_class.new.present(talent_learning_path: talent_learning_path)).to eq expected_response
    end

    it 'return nil when talent learning path is nil' do
      expect(described_class.new.present(talent_learning_path: nil)).to eq nil
    end
  end
end
