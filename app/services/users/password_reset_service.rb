# frozen_string_literal: true

module Users
  # パスワードリセットメール送信ロジックを担う Service。
  #
  # 依存性の注入:
  #   user_repository — テスト時に User をモック可能
  #   mailer          — テスト時に PasswordResetMailer をモック可能
  class PasswordResetService
    attr_reader :user

    def initialize(email:, user_repository: User, mailer: PasswordResetMailer)
      @email           = email
      @user_repository = user_repository
      @mailer          = mailer
    end

    # ユーザーが見つかればメール送信して true を返す。
    # 見つからなければ false を返す（例外は raise しない）。
    def call
      @user = @user_repository.find_by(email: @email)
      return false unless @user

      @mailer.with(user: @user).reset.deliver_later
      true
    end
  end
end
