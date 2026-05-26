# frozen_string_literal: true

# ゲストユーザーが制限されている操作を試みた場合に raise する
class GuestOperationError < ApplicationError; end
