# frozen_string_literal: true

module Api
  module V1
    class TalentLearningPathPresenter
      def present(talent_learning_path:)
        return unless talent_learning_path

        {
          id: talent_learning_path.id,
          learning_path: learning_path_presenter.present(
            learning_path: LearningPath.includes(:courses, :author).find_by(id: talent_learning_path.learning_path_id)
          ),
          current_talent_course: talent_course_presenter.present(
            talent_course: talent_learning_path.current_talent_course
          )
        }
      end

      private

      def talent_course_presenter
        @talent_course_presenter ||= Api::V1::TalentCoursePresenter.new
      end

      def user_presenter
        @user_presenter ||= Api::V1::UserPresenter.new
      end

      def learning_path_presenter
        @learning_path_presenter ||= Api::V1::LearningPathPresenter.new
      end
    end
  end
end
