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
      rescue ActiveRecord::InvalidForeignKey => e
        ResultError.new(errors: [e.message], status: :unprocessable_entity)
      end

      def update(talent_course:, params:)
        return ResultSuccess.new unless params[:status].present?

        talent_course.status = params[:status]
        if params[:status] == 'Completed'
          talent_course.finished_at = DateTime.current
          # TODO: please put it later in background job
          talent_learning_path_service.shift_to_next_course(talent_course: talent_course)
        end

        return ResultSuccess.new if talent_course.save

        ResultError.new(errors: talent_course.errors.full_messages)
      end

      private

      def talent_course_presenter
        @talent_course_presenter ||= Api::V1::TalentCoursePresenter.new
      end

      def talent_learning_path_service
        @talent_learning_path_service ||= Api::V1::TalentLearningPathService.new
      end
    end
  end
end
