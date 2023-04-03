# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::BaseController
      before_action -> { validate_user(params[:id]) }, only: %i[show destroy update]
      before_action :validate_transfer_to, only: %i[destroy]

      # GET /api/v1/users
      def index
        result = user_service.index
        render json: result.attributes[:users], status: :ok
      end

      # GET /api/v1/users/{id}
      def show
        result = user_service.show(user: @user)
        return render json: result.attributes[:user], status: :ok if result.successful?

        render json: result.attributes, status: result.status
      end

      # PUT /api/v1/users/{id}
      def update
        result = user_service.update(user: @user, user_params: user_params)
        if result.successful?
          head :no_content
        else
          render json: result.attributes, status: result.status
        end
      end

      # POST /api/v1/users
      def create
        result = user_service.create(user_params: user_params)
        if result.successful?
          render json: result.attributes[:user], status: :created
        else
          render json: result.attributes, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/{id}
      def destroy
        result = user_service.destroy(user: @user, params: transfer_to_params)
        if result.successful?
          head :no_content
        else
          render json: result.attributes, status: result.status
        end
      end

      private

      def user_params
        params.fetch(:user, {}).permit(:username, :email, :password, :password_confirmation)
      end

      def transfer_to_params
        params.permit(:transfer_to)
      end

      def user_service
        @user_service ||= Api::V1::UserService.new
      end

      def transfer_to_exist?(user_id)
        User.where(id: user_id).exists?
      end

      def validate_transfer_to
        return unless transfer_to_params[:transfer_to].present?

        if transfer_to_params[:transfer_to].to_i == @user.id
          render json: { errors: [I18n.t('errors.messages.alternate_author_should_not_be_original_author')] },
                 status: :bad_request
        end

        return if transfer_to_exist?(transfer_to_params[:transfer_to])

        render json: { errors: [I18n.t('errors.messages.not_found', parameter_name: :Alternate_auther)] },
               status: :bad_request
      end
    end
  end
end
