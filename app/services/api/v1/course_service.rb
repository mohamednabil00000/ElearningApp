# frozen_string_literal: true

module Api
  module V1
    class CourseService
      def index
        courses = Course.includes(:author).all
        ResultSuccess.new(courses: course_presenter.present_all(courses: courses))
      end

      def create(course_params:)
        course = Course.new(course_params)
        if course.save
          ResultSuccess.new(course: course_presenter.present(course: course))
        else
          ResultError.new(errors: course.errors.full_messages)
        end
      end

      def update(course:, course_params:)
        return ResultSuccess.new if course.update(course_params)

        ResultError.new(errors: course.errors.full_messages, status: :unprocessable_entity)
      end

      def show(course:)
        ResultSuccess.new(course: course_presenter.present(course: course))
      end

      def destroy(course:)
        return ResultSuccess.new if course.destroy

        ResultError.new(errors: course.errors.full_messages, status: :unprocessable_entity)
      end

      private

      def course_presenter
        @course_presenter ||= Api::V1::CoursePresenter.new
      end
    end
  end
end
