# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ActionController::API
      def create
        user = User.find_by(email: params[:email])

        if user&.password == params[:password]
          token = JwtService.encode(user_id: user.id)
          render json: { token: token, user: { id: user.id, name: user.name, email: user.email } }
        else
          render json: { error: "メールアドレスまたはパスワードが正しくありません" }, status: :unauthorized
        end
      end
    end
  end
end
