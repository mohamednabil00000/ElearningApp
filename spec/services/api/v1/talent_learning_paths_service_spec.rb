# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TalentLearningPathService do
  let(:author) { create(:user) }
  let(:course1) { create(:course, author_id: author.id) }
  let(:course2) { create(:course, author_id: author.id) }
  let(:talent) { create(:user) }
  let!(:talent_course) { create(:talent_course, course_id: course1.id, talent_id: talent.id) }
  let(:learning_path) do
    create :learning_path, name: 'learning_path1', author_id: author.id, course_ids: [course1.id, course2.id]
  end
  let(:subject) { described_class.new }

  describe '#create' do
    context 'return success' do
      it 'when the talent assigned successfully for a given learning path' do
        expect do
          result = subject.create(learning_path: learning_path, talent: talent)
          expect(result).to be_successful
          talent_learning_path = TalentLearningPath.last
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
          expect(result.attributes[:talent_learning_path]).to eq expected_response
        end.to change(TalentLearningPath, :count).by(1)
      end

      it 'when the talent already completed the first course before assigning it from learning path' do
        talent_course2 = create(:talent_course, course_id: course2.id, talent_id: talent.id)
        talent_course.status = 'Completed'
        talent_course.save

        expect do
          result = subject.create(learning_path: learning_path, talent: talent)
          expect(result).to be_successful
          talent_learning_path = TalentLearningPath.last
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
          }
          expect(result.attributes[:talent_learning_path]).to eq expected_response
        end.to change(TalentLearningPath, :count).by(1)
      end
    end

    context 'return failure' do
      it 'when the same talent assigned twice to the same learning path' do
        create :talent_learning_path, talent_id: talent.id, learning_path_id: learning_path.id,
                                      current_talent_course_id: talent_course.id
        result = subject.create(learning_path: learning_path, talent: talent)
        expect(result).not_to be_successful
        expect(result.attributes[:errors])
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
        result = subject.show(talent_learning_path: talent_learning_path)
        expect(result).to be_successful

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
        expect(result.attributes[:talent_learning_path]).to eq expected_response
      end
    end
  end

  describe '#destroy' do
    context 'return success' do
      it 'when the record deleted successfully' do
        create :talent_learning_path, talent_id: talent.id, learning_path_id: learning_path.id,
                                      current_talent_course_id: talent_course.id
        expect do
          result = subject.destroy(learning_path_id: learning_path.id, talent_id: talent.id)
          expect(result).to be_successful
        end.to change(TalentLearningPath, :count).by(-1)
      end

      it 'when the talent and learning path does not exist' do
        expect do
          result = subject.destroy(learning_path_id: 12_345, talent_id: 12_345)
          expect(result).to be_successful
        end.not_to change(TalentLearningPath, :count)
      end
    end
  end
end
