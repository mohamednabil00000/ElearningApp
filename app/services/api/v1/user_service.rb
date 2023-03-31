# frozen_string_literal: true

module Api
  module V1
    class UserService
      def create(user_params:)
        user = User.new(user_params)
        if user.save
          ResultSuccess.new(user: user_presenter.present(user: user))
        else
          ResultError.new(errors: user.errors.full_messages)
        end
      end

      def update(user:, user_params:)
        return ResultSuccess.new if user.update(user_params)

        ResultError.new(errors: user.errors.full_messages)
      end

      def show(user:)
        return ResultError.new unless user

        ResultSuccess.new(user: user_presenter.present(user: user))
      end

      private

      def user_presenter
        @user_presenter ||= Api::V1::UserPresenter.new
      end
    end
  end
end
