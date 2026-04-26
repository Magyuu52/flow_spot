# frozen_string_literal: true

module OwnerAuthorizable
  extend ActiveSupport::Concern

  private

  # 共通の枠: 認可チェックに失敗したら AuthorizationError を raise する責務を一元化。
  # 可変部分（誰がオーナーか）は各コントローラが ensure_owner? を実装して定義する。
  def ensure_correct_user
    raise AuthorizationError unless ensure_owner?
  end

  # サブクラスで必ず実装する。実装忘れを NotImplementedError で実行時に検知する。
  def ensure_owner?
    raise NotImplementedError, "#{self.class} は ensure_owner? を実装してください"
  end
end
