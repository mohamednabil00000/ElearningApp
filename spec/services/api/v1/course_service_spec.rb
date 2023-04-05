# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CourseService do
  let(:subject) { described_class.new }
  let!(:author) { create(:user) }

  describe '#create' do
    context 'return success' do
      let(:params) do
        {
          name: 'course1',
          path: '/path1',
          author_id: author.id
        }
      end

      it 'when user created successfully' do
        expect do
          result = subject.create(course_params: params)
          expect(result).to be_successful
          expected_res = {
            path: '/path1',
            id: Course.first.id,
            name: 'course1',
            author: {
              id: author.id,
              username: author.username,
              email: author.email
            }
          }
          expect(result.attributes[:course]).to eq expected_res
        end.to change(Course, :count).by(1)
      end

      it 'when we have two same courses but diff authors' do
        create :course, name: 'course1', author_id: author.id
        author2 = create :user
        expect do
          params = { name: 'course1', author_id: author2.id,
                     path: '/path1' }

          result = subject.create(course_params: params)
          expect(result).to be_successful
          course = Course.last
          expected_response = {
            path: course.path,
            id: course.id,
            name: course.name,
            author: {
              id: author2.id,
              username: author2.username,
              email: author2.email
            }
          }
          expect(result.attributes[:course]).to eq expected_response
        end.to change(Course, :count).by(1)
      end
    end

    context 'return failure' do
      it 'when the course exists before with the same author' do
        create :course, name: 'course1', author_id: author.id
        expect do
          params = { name: 'course1', author_id: author.id, path: '/path1' }
          result = subject.create(course_params: params)
          expect(result).not_to be_successful
          expect(result.attributes[:errors]).to contain_exactly('Name has already been taken')
        end.not_to change(Course, :count)
      end

      it 'when the author does not exist' do
        expect do
          params = { name: 'course1', path: '/path1' }
          result = subject.create(course_params: params)
          expect(result).not_to be_successful
          expect(result.attributes[:errors]).to contain_exactly('Author must exist')
        end.not_to change(Course, :count)
      end
    end
  end

  describe '#update' do
    let!(:author2) { create(:user) }
    let!(:course) { create(:course, author: author) }

    context 'return success' do
      it 'when doing full update' do
        expect do
          params = { name: 'course1', path: '/path1', author_id: author2.id }
          result = subject.update(course: course, course_params: params)
          expect(result).to be_successful
          updated_course = Course.find_by(id: course.id)
          expect(updated_course.name).to eq 'course1'
          expect(updated_course.path).to eq '/path1'
          expect(updated_course.author_id).to eq author2.id
        end.not_to change(Course, :count)
      end

      it 'when doing partial update' do
        expect do
          params = { name: 'course1', path: '/path1' }
          result = subject.update(course: course, course_params: params)
          expect(result).to be_successful
          updated_course = Course.find_by(id: course.id)
          expect(updated_course.name).to eq 'course1'
          expect(updated_course.path).to eq '/path1'
          expect(updated_course.author_id).to eq author.id
        end.not_to change(Course, :count)
      end

      it 'when update the name to exist one but for another author' do
        create :course, name: 'course2', author_id: author2.id
        expect do
          params = { name: 'course2' }
          result = subject.update(course: course, course_params: params)
          expect(result).to be_successful
          updated_course = Course.find_by(id: course.id)
          expect(updated_course.name).to eq 'course2'
          expect(updated_course.path).to eq course.path
          expect(updated_course.author_id).to eq author.id
        end.not_to change(Course, :count)
      end
    end

    context 'return failure' do
      it 'when update name to exist one before with the same author' do
        create :course, name: 'course2', author_id: author.id
        params = { name: 'course2' }
        result = subject.update(course: course, course_params: params)
        expect(result).not_to be_successful
        expect(result.attributes[:errors]).to contain_exactly('Name has already been taken')
      end

      it 'when the updated author does not exist' do
        params = { author_id: 123_456 }
        result = subject.update(course: course, course_params: params)
        expect(result).not_to be_successful
        expect(result.attributes[:errors]).to contain_exactly 'Author must exist'
      end
    end
  end

  describe '#show' do
    let!(:course) { create(:course, author: author) }

    context 'return success' do
      it 'return course json object' do
        result = subject.show(course: course)
        expect(result).to be_successful
        expected_response = {
          path: course.path,
          id: course.id,
          name: course.name,
          author: {
            id: author.id,
            username: author.username,
            email: author.email
          }
        }
        expect(result.attributes[:course]).to eq expected_response
      end
    end
  end

  describe '#destroy' do
    let!(:course) { create(:course, author: author) }

    context 'return success' do
      it 'when the course deleted successfully' do
        result = subject.destroy(course: course)

        expect(result).to be_successful
      end
    end
  end

  describe '#index' do
    context 'return success' do
      it 'when return courses successfully' do
        author2 = create(:user)
        course1 = create(:course, author: author)
        course2 = create(:course, author: author2)

        result = subject.index
        expect(result).to be_successful
        expect(result.attributes[:courses]).to match_array([
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
                                                                 id: author2.id,
                                                                 username: author2.username,
                                                                 email: author2.email
                                                               }
                                                             }
                                                           ])
      end

      it 'when return empty' do
        result = subject.index
        expect(result).to be_successful
        expect(result.attributes[:courses]).to eq []
      end
    end
  end
end
