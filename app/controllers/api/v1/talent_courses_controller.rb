# frozen_string_literal: true

module Api
  module V1
    class TalentCoursesController < Api::V1::BaseController
      before_action -> { validate_course(params[:course_id]) }, only: %i[create]
      before_action -> { validate_user(params[:talent_id]) }, only: %i[create]
      before_action :validate_talent_not_author, only: %i[create]
      before_action :validate_talent_course, only: %i[update]

      # POST /api/v1/talents/:talent_id/courses/:course_id
      def create
        result = talent_course_service.create(course_id: @course.id, talent_id: @user.id)
        if result.successful?
          head :ok
        else
          render json: result.attributes, status: :unprocessable_entity
        end
      end

      # GET /api/v1/talent_courses
      def index
        result = talent_course_service.index
        render json: result.attributes, status: :ok
      end

      # Delete /api/v1/talents/:talent_id/courses/:course_id
      def destroy
        result = talent_course_service.destroy(course_id: params[:course_id], talent_id: params[:talent_id])
        if result.successful?
          head :no_content
        else
          render json: result.attributes, status: :unprocessable_entity
        end
      end

      # Patch /api/v1/talent_courses/:id
      def update
        result = talent_course_service.update(talent_course: @talent_course, params: update_params)
        if result.successful?
          head :no_content
        else
          render json: result.attributes, status: :unprocessable_entity
        end
      end

      private

      def talent_course_service
        @talent_course_service ||= Api::V1::TalentCourseService.new
      end

      def update_params
        params.permit(:status)
      end
    end
  end
end
