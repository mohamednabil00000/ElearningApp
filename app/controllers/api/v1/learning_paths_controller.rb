# frozen_string_literal: true

module Api
  module V1
    class LearningPathsController < Api::V1::BaseController
      before_action -> { validate_learning_path(params[:id]) }, only: %i[destroy update]

      # POST /api/v1/learning_paths
      def create
        result = learning_path_service.create(learning_path_params: learning_path_params)
        if result.successful?
          render json: result.attributes[:learning_path], status: :created
        else
          render json: result.attributes, status: result.status
        end
      end

      # PUT /api/v1/learning_paths/:id
      def update
        result = learning_path_service.update(learning_path: @learning_path, learning_path_params: learning_path_params)
        if result.successful?
          head :no_content
        else
          render json: result.attributes, status: result.status
        end
      end

      # DELETE /api/v1/learning_paths/:id
      def destroy
        result = learning_path_service.destroy(learning_path: @learning_path)
        if result.successful?
          head :no_content
        else
          render json: result.attributes, status: result.status
        end
      end

      # GET /api/v1/learning_paths
      def index
        # TO-DO pagination
        result = learning_path_service.index

        render json: result.attributes[:learning_paths], status: :ok
      end

      private

      def learning_path_service
        @learning_path_service ||= Api::V1::LearningPathService.new
      end

      def learning_path_params
        params
          .require(:learning_path)
          .permit(
            :name,
            :author_id,
            course_ids: []
          )
      end
    end
  end
end
