# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def search?  = true
  def create?  = not_guest?
  def update?  = owner? || admin?
  def destroy? = owner? || moderator_or_above?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  private

  def owner?
    logged_in? && record.user_id == user.id
  end
end
