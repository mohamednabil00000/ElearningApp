# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TalentCoursePresenter do
  let(:author) { create :user }
  let(:talent) { create :user }
  let(:course1) { (create :course, author: author) }
  let(:course2) { (create :course, author: author) }

  describe '#present' do
    it 'return expected talent course object' do
      talent_course = create(:talent_course, course_id: course1.id, talent_id: talent.id)

      expected_res = {
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
      expect(described_class.new.present(talent_course: talent_course)).to eq expected_res
    end

    it 'return nil when talent course is nil' do
      expect(described_class.new.present(talent_course: nil)).to eq nil
    end
  end

  describe '#present_all' do
    it 'return all elements' do
      talent_course1 = create(:talent_course, course_id: course1.id, talent_id: talent.id, status: 'In_progress')
      talent_course2 = create(:talent_course, course_id: course2.id, talent_id: talent.id)

      expected_res = [
        {
          finished_at: nil,
          id: talent_course1.id,
          status: 'In_progress',
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
        },
        {
          finished_at: nil,
          id: talent_course2.id,
          status: 'Not_started_yet',
          course: {
            path: course2.path,
            id: course2.id,
            name: course2.name,
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
      ]
      expect(described_class.new.present_all(talent_courses: TalentCourse.all.includes(:course))).to eq expected_res
    end
  end
end
