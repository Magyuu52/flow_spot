# frozen_string_literal: true

class LikePolicy < ApplicationPolicy
  def create?  = not_guest?
  def destroy? = not_guest?
end
