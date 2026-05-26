# frozen_string_literal: true

# 未ログインのユーザーがログイン必須ページにアクセスした場合に raise する
class AuthenticationError < ApplicationError; end
