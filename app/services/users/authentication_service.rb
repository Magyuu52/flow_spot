# frozen_string_literal: true

module Users
  # ログイン認証ロジックを担う Service。
  #
  # 依存性の注入: user_repository を外から受け取ることで
  # テスト時に DB を使わずモックで検証できる。
  class AuthenticationService
    attr_reader :user

    def initialize(email:, password:, user_repository: User)
      @email           = email
      @password        = password
      @user_repository = user_repository
    end

    # 認証成否を真偽値で返す。成功時は #user で認証済みユーザーを取得できる。
    def call
      @user = @user_repository.find_by(email: @email, password: @password)
      @user.present?
    end
  end
end
