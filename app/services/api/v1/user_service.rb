# frozen_string_literal: true

module Api
  module V1
    class UserService
      def index
        # TODO: pagination
        users = User.all
        ResultSuccess.new(users: user_presenter.present_all(users: users))
      end

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

        ResultError.new(errors: user.errors.full_messages, status: :unprocessable_entity)
      end

      def show(user:)
        ResultSuccess.new(user: user_presenter.present(user: user))
      end

      def destroy(user:, params:)
        return destroy_author(user, params) if auther?(user)

        destroy_user(user)
      end

      private

      def user_presenter
        @user_presenter ||= Api::V1::UserPresenter.new
      end

      def auther?(user)
        Course.where(author_id: user.id).exists?
      end

      def destroy_author(user, params)
        unless params[:transfer_to].present?
          return ResultError.new(errors: [I18n.t('errors.messages.this_user_is_author_for_some_courses')],
                                 status: :bad_request)
        end

        Course.where(author_id: user.id).update(author_id: params[:transfer_to])
        destroy_user(user)
      end

      def destroy_user(user)
        user.destroy
        ResultSuccess.new
      end
    end
  end
end
