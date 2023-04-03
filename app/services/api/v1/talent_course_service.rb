# frozen_string_literal: true

module Api
  module V1
    class TalentCourseService
      def create(course_id:, talent_id:)
        talent_course = TalentCourse.new(course_id: course_id, talent_id: talent_id)
        if talent_course.save
          ResultSuccess.new
        else
          ResultError.new(errors: talent_course.errors.full_messages)
        end
      end

      def index
        talent_courses = TalentCourse.includes(:course, :talent).all
        ResultSuccess.new(talent_courses: talent_course_presenter.present_all(talent_courses: talent_courses))
      end

      def destroy(course_id:, talent_id:)
        talent_course = TalentCourse.find_by(course_id: course_id, talent_id: talent_id)
        talent_course&.destroy
        ResultSuccess.new
      end

      def update(talent_course:, params:)
        talent_course.status = params[:status]
        talent_course.finished_at = DateTime.current if params[:status] == 'Completed'

        return ResultSuccess.new if talent_course.save

        ResultError.new(errors: talent_course.errors.full_messages)
      end

      private

      def talent_course_presenter
        @talent_course_presenter ||= Api::V1::TalentCoursePresenter.new
      end
    end
  end
end
