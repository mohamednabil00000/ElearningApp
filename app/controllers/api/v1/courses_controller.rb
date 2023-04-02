# frozen_string_literal: true

module Api
  module V1
    class CoursesController < Api::V1::BaseController
      before_action :set_course, only: %i[show destroy update]

      # GET /api/v1/courses
      def index
        # TO-DO pagination
        result = course_service.index

        render json: result.attributes[:courses], status: :ok
      end

      # GET /api/v1/courses/{id}
      def show
        result = course_service.show(course: @course)
        return head :not_found unless result.successful?

        render json: result.attributes[:course], status: :ok
      end

      # PUT /api/v1/courses/{id}
      def update
        result = course_service.update(course: @course, course_params: course_params)
        if result.successful?
          head :no_content
        else
          render json: result.attributes, status: result.attributes[:status]
        end
      end

      # POST /api/v1/courses
      def create
        result = course_service.create(course_params: course_params)
        if result.successful?
          render json: result.attributes[:course], status: :created
        else
          render json: result.attributes, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/courses/{id}
      def destroy
        result = course_service.destroy(course: @course)
        if result.successful?
          head :no_content
        else
          render json: result.attributes, status: result.attributes[:status]
        end
      end

      private

      def course_params
        params.fetch(:course, {}).permit(:name, :path, :author_id)
      end

      def set_course
        @course = Course.find_by(id: params[:id])
      end

      def course_service
        @course_service ||= Api::V1::CourseService.new
      end
    end
  end
end
