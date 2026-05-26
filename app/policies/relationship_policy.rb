# frozen_string_literal: true

class RelationshipPolicy < ApplicationPolicy
  def create?     = not_guest?
  def destroy?    = not_guest?
  def followings? = true
  def followers?  = true
end
