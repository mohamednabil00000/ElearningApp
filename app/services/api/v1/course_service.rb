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
        if course.destroy
          # TODO: This one should be in background job
          learning_path_service.destroy_empty_learning_paths
          return ResultSuccess.new
        end

        ResultError.new(errors: course.errors.full_messages, status: :unprocessable_entity)
      rescue ActiveRecord::InvalidForeignKey => e
        ResultError.new(errors: [e.message], status: :unprocessable_entity)
      end

      private

      def course_presenter
        @course_presenter ||= Api::V1::CoursePresenter.new
      end

      def learning_path_service
        @learning_path_service ||= Api::V1::LearningPathService.new
      end
    end
  end
end
