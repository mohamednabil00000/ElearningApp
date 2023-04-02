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
          author: Api::V1::UserPresenter.new.present(user: course.author)
        }
      end

      def present_all(courses:)
        courses.map do |course|
          present(course: course)
        end
      end
    end
  end
end
