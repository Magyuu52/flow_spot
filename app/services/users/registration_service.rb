# frozen_string_literal: true

module Users
  # ユーザー登録の生成ロジックを担う Service。
  # コントローラはセッション操作とリダイレクトのみに集中できる。
  #
  # 依存性の注入: user_repository を外から受け取ることで
  # テスト時に本物の User クラスをモックに差し替えられる。
  class RegistrationService
    attr_reader :user

    def initialize(params:, user_repository: User)
      @params          = params
      @user_repository = user_repository
      @user            = @user_repository.new(@params)
    end

    # 登録成否を真偽値で返す
    def call
      @user.save
    end
  end
end
