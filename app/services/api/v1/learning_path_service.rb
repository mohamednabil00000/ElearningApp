# frozen_string_literal: true

module Api
  module V1
    class LearningPathService
      def create(learning_path_params:)
        if learning_path_params[:course_ids].present?
          learning_path_params[:course_ids] = learning_path_params[:course_ids].uniq
        end
        learning_path = LearningPath.new(learning_path_params)
        if learning_path.save
          ResultSuccess.new(learning_path: learning_path_presenter.present(learning_path: learning_path))
        else
          ResultError.new(errors: learning_path.errors.full_messages, status: :unprocessable_entity)
        end
      rescue ActiveRecord::RecordNotFound => e
        ResultError.new(errors: [e.message], status: :not_found)
      end

      def update(learning_path:, learning_path_params:)
        if learning_path_params[:course_ids].present?
          # to update the new order of courses.
          # in case the old courses are [1,2] and new one is [2,1]
          # so if we didn't delete the old courses, nothing will change.
          learning_path.courses.delete_all
        end
        return ResultSuccess.new if learning_path.update(learning_path_params)

        ResultError.new(errors: learning_path.errors.full_messages, status: :unprocessable_entity)
      rescue ActiveRecord::RecordNotFound => e
        ResultError.new(errors: [e.message], status: :not_found)
      end

      def destroy(learning_path:)
        return ResultSuccess.new if learning_path.destroy

        ResultError.new(errors: learning_path.errors.full_messages, status: :unprocessable_entity)
      end

      def index
        learning_paths = LearningPath.includes(:author, :courses).all
        ResultSuccess.new(learning_paths: learning_path_presenter.present_all(learning_paths: learning_paths))
      end

      def destroy_empty_learning_paths
        LearningPath.left_outer_joins(:learning_path_courses)
                    .where('learning_path_courses.learning_path_id': nil).delete_all
      end

      private

      def learning_path_presenter
        @learning_path_presenter ||= Api::V1::LearningPathPresenter.new
      end
    end
  end
end
