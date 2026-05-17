# frozen_string_literal: true

module OwnerAuthorizable
  extend ActiveSupport::Concern

  class_methods do
    # owner_resource :post のように宣言すると ensure_owner? が動的に定義される。
    #
    # define_method を使う理由:
    #   - メソッド名 :ensure_owner? がコード上に明示され grep/IDE検索で追跡可能
    #   - method_missing と異なり respond_to? にも正しく応答する
    #   - 生成の入口を owner_resource 一箇所に限定し、変更箇所を局所化する
    def owner_resource(resource_name)
      klass = resource_name.to_s.classify.constantize

      define_method(:ensure_owner?) do
        resource = instance_variable_get("@#{resource_name}") ||
                   klass.find(params[:id])
        instance_variable_set("@#{resource_name}", resource)
        resource.user_id == @current_user.id
      end
      private :ensure_owner?
    end
  end

  private

  def ensure_correct_user
    raise AuthorizationError unless ensure_owner?
  end

  # owner_resource を宣言しなかったコントローラでの実装忘れを実行時に検知する。
  def ensure_owner?
    raise NotImplementedError, "#{self.class} は ensure_owner? を実装してください"
  end
end
