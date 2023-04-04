# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::LearningPathPresenter do
  let!(:author) { create(:user) }
  let!(:author2) { create(:user) }
  let!(:course1) { create(:course, author_id: author.id) }
  let!(:course2) { create(:course, author_id: author.id) }

  describe '#present' do
    it 'return expected learning path object' do
      learning_path = create(:learning_path, author: author, course_ids: [course1.id, course2.id])

      expected_response = {
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
      }
      expect(described_class.new.present(learning_path: learning_path)).to eq expected_response
    end

    it 'return nil when learning path is nil' do
      expect(described_class.new.present(learning_path: nil)).to eq nil
    end
  end

  describe '#present_all' do
    it 'return all elements' do
      learning_path1 = create(:learning_path, author: author, course_ids: [course1.id, course2.id])
      learning_path2 = create(:learning_path, author: author, course_ids: [course1.id, course2.id])

      expected_response = [
        {
          id: learning_path1.id,
          name: learning_path1.name,
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
        {
          id: learning_path2.id,
          name: learning_path2.name,
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
        }
      ]
      expect(described_class.new.present_all(learning_paths: LearningPath.includes(:courses,
                                                                                   :author))).to eq expected_response
    end

    it 'when learning path table is empty' do
      expect(described_class.new.present_all(learning_paths: LearningPath.all)).to eq []
    end
  end
end
