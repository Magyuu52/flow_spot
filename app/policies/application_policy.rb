# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?   = false
  def show?    = false
  def new?     = create?
  def create?  = false
  def edit?    = update?
  def update?  = false
  def destroy? = false

  def search?  = false

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  private

  def logged_in?
    user.present?
  end

  def not_guest?
    logged_in? && !user.guest?
  end

  def admin?
    logged_in? && user.admin?
  end

  def moderator_or_above?
    logged_in? && (user.moderator? || user.admin?)
  end

  def owner?
    raise NotImplementedError, "#{self.class} は owner? を実装してください"
  end
end
