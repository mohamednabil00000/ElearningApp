# frozen_string_literal: true

module Api
  module V1
    class BaseController < Api::BaseController
      def validate_user
        @user = User.find_by(id: params[:id])
        return if @user

        render json: { errors: [I18n.t('errors.messages.not_found', parameter_name: :User)] }, status: :not_found
      end

      def validate_course
        @course = Course.find_by(id: params[:id])
        return if @course

        render json: { errors: [I18n.t('errors.messages.not_found', parameter_name: :Course)] }, status: :not_found
      end
    end
  end
end
