# frozen_string_literal: true

require 'spec_helper'

describe Api::V1::CoursePresenter do
  let!(:author) { create :user }

  describe '#present' do
    let!(:course) { create(:course, author: author) }

    it 'return expected course object' do
      expected_res = {
        path: course.path,
        id: course.id,
        name: course.name,
        author: {
          id: author.id,
          username: author.username,
          email: author.email
        }
      }
      expect(described_class.new.present(course: course)).to eq expected_res
    end

    it 'return nil when course is nil' do
      expect(described_class.new.present(course: nil)).to eq nil
    end
  end

  describe '#present_all' do
    it 'return all elements' do
      course1 = create(:course, author: author)
      course2 = create(:course, author: author)
      expected_res = [
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
      expect(described_class.new.present_all(courses: Course.all)).to eq expected_res
    end

    it 'when courses table is empty' do
      expect(described_class.new.present_all(courses: Course.all)).to eq []
    end
  end
end
