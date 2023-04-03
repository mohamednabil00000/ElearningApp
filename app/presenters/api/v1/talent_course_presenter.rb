# frozen_string_literal: true

module Api
  module V1
    class TalentCoursePresenter
      def present(talent_course:)
        return unless talent_course

        {
          id: talent_course.id,
          status: talent_course.status,
          finished_at: talent_course.finished_at,
          course: course_presenter.present(course: talent_course.course),
          talent: user_presenter.present(user: talent_course.talent)
        }
      end

      def present_all(talent_courses:)
        talent_courses.map do |talent_course|
          present(talent_course: talent_course)
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
