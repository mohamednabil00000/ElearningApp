# frozen_string_literal: true

# user controller
module Api
  module V1
    class UsersController < Api::V1::BaseController
      before_action :set_user, only: %i[show destroy update]

      # GET /api/v1/users
      def index
        # TO-DO pagination
        render json: User.all.select(:id, :email, :username), status: :ok
      end

      # GET /api/v1/users/{id}
      def show
        result = user_service.show(user: @user)
        return head :not_found unless result.successful?

        render json: result.attributes[:user], status: :ok
      end

      # PUT /api/v1/users/{id}
      def update
        result = user_service.update(user: @user, user_params: user_params)
        if result.successful?
          head :no_content
        else
          render json: result.attributes, status: :unprocessable_entity
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
        # TO-DO later
      end

      private

      def user_params
        params.fetch(:user, {}).permit(:username, :email, :password, :password_confirmation)
      end

      def set_user
        @user = User.find_by(id: params[:id])
      end

      def user_service
        @user_service ||= Api::V1::UserService.new
      end
    end
  end
end
