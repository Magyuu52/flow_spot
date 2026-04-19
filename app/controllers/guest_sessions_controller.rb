# frozen_string_literal: true

class GuestSessionsController < ApplicationController
  def create
    user = User.find_or_create_by(name: Constants::GUEST_NAME, email: Constants::GUEST_EMAIL) do |user|
      guest_password        = User.generate_guest_password
      user.password         = guest_password
      user.password_confirm = guest_password
    end
    session[:user_id] = user.id
    flash[:notice] = "ゲストユーザーとしてログインしました"
    redirect_to root_path
  end
end
