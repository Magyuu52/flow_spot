# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_jwt!

      rescue_from Pundit::NotAuthorizedError do |_e|
        render json: { error: "この操作を行う権限がありません" }, status: :forbidden
      end

      private

      def authenticate_jwt!
        token = extract_token_from_header
        payload = JwtService.decode(token)
        @current_user = User.find_by(id: payload["user_id"])
        render json: { error: "認証に失敗しました" }, status: :unauthorized unless @current_user
      rescue JwtService::DecodeError
        render json: { error: "トークンが無効または期限切れです" }, status: :unauthorized
      end

      def current_user
        @current_user
      end

      def extract_token_from_header
        header = request.headers["Authorization"]
        header&.split(" ")&.last
      end
    end
  end
end
