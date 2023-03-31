# frozen_string_literal: true

# user presenter
class Api::V1::UserPresenter
  def present(user:)
    return unless user

    {
      id: user.id,
      email: user.email,
      username: user.username
    }
  end

  def present_arr(users:)
    users.map do |user|
      present(user: user)
    end
  end
end
