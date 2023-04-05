# frozen_string_literal: true

module Api
  module V1
    class TalentLearningPathsController < Api::V1::BaseController
      before_action -> { validate_user(params[:talent_id]) }, only: %i[create]
      before_action -> { validate_learning_path(params[:learning_path_id]) }, only: %i[create]
      before_action -> { validate_talent_learning_path(params[:id]) }, only: %i[show]

      # POST /api/v1/talents/:talent_id/learning_paths/:learning_path_id
      def create
        result = talent_learning_path_service.create(learning_path: @learning_path, talent: @user)
        if result.successful?
          render json: result.attributes[:talent_learning_path], status: :created
        else
          render json: result.attributes, status: :unprocessable_entity
        end
      end

      # Delete /api/v1/talents/:talent_id/learning_paths/:learning_path_id
      def destroy
        result = talent_learning_path_service.destroy(learning_path_id: params[:learning_path_id],
                                                      talent_id: params[:talent_id])
        if result.successful?
          head :no_content
        else
          render json: result.attributes, status: :unprocessable_entity
        end
      end

      # GET /api/v1/talent_learning_paths/:id
      def show
        result = talent_learning_path_service.show(talent_learning_path: @talent_learning_path)
        return render json: result.attributes[:talent_learning_path], status: :ok if result.successful?

        render json: result.attributes, status: result.status
      end

      private

      def talent_learning_path_service
        @talent_learning_path_service ||= Api::V1::TalentLearningPathService.new
      end
    end
  end
end
