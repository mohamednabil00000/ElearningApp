# frozen_string_literal: true

module Api
  module V1
    class BaseController < Api::BaseController
      def validate_user(user_id)
        @user = User.find_by(id: user_id)
        return if @user

        render json: { errors: [I18n.t('errors.messages.not_found', parameter_name: :User)] }, status: :not_found
      end

      def validate_course(course_id)
        @course = Course.find_by(id: course_id)
        return if @course

        render json: { errors: [I18n.t('errors.messages.not_found', parameter_name: :Course)] }, status: :not_found
      end

      def validate_learning_path(learning_path_id)
        @learning_path = LearningPath.find_by(id: learning_path_id)
        return if @learning_path

        render json: { errors: [I18n.t('errors.messages.not_found', parameter_name: :Learning_path)] },
               status: :not_found
      end

      def validate_talent_not_author
        return unless @user.id == @course.author_id

        render json: { errors: [I18n.t('errors.messages.talent_should_not_be_the_author')] }, status: :bad_request
      end

      def validate_talent_course
        @talent_course = TalentCourse.find_by(id: params[:id])
        return if @talent_course

        render json: { errors: [I18n.t('errors.messages.not_found', parameter_name: :Talent_course)] },
               status: :not_found
      end
    end
  end
end
