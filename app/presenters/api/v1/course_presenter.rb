# frozen_string_literal: true

module Api
  module V1
    class CoursePresenter
      def present(course:)
        return unless course

        {
          id: course.id,
          path: course.path,
          name: course.name,
          author: user_presenter.present(user: course.author)
        }
      end

      def present_all(courses:)
        courses.map do |course|
          present(course: course)
        end
      end

      private

      def user_presenter
        @user_presenter ||= Api::V1::UserPresenter.new
      end
    end
  end
end
