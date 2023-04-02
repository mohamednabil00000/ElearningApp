# frozen_string_literal: true

module Api
  module V1
    class UserPresenter
      def present(user:)
        return unless user

        {
          id: user.id,
          email: user.email,
          username: user.username
        }
      end

      def present_all(users:)
        users.map do |user|
          present(user: user)
        end
      end
    end
  end
end
