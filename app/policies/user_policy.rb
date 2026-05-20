# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def search?  = true
  def create?  = true
  def update?  = owner? || admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  private

  def owner?
    logged_in? && record.id == user.id
  end
end
