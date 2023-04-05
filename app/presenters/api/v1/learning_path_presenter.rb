# frozen_string_literal: true

module Api
  module V1
    class LearningPathPresenter
      def present(learning_path:)
        return unless learning_path

        {
          id: learning_path.id,
          name: learning_path.name,
          author: user_presenter.present(user: learning_path.author),
          courses: course_presenter.present_all(courses: learning_path.courses)
        }
      end

      def present_all(learning_paths:)
        learning_paths.map do |learning_path|
          present(learning_path: learning_path)
        end
      end

      private

      def course_presenter
        @course_presenter ||= Api::V1::CoursePresenter.new
      end

      def user_presenter
        @user_presenter ||= Api::V1::UserPresenter.new
      end
    end
  end
end
