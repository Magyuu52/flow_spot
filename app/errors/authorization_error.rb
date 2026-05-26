# frozen_string_literal: true

# ログイン済みだが対象リソースへの操作権限がない場合に raise する
class AuthorizationError < ApplicationError; end
