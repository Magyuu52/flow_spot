class GuestSessionsController < ApplicationController
  def create
    user = User.find_or_create_by(name: "ゲストユーザー", email: "guest@example.com") do |user|
      user.password = SecureRandom.alphanumeric(10) + [*'a'..'z'].sample(1).join + [*'0'..'9'].sample(1).join
      user.password_confirm = user.password
    end
    session[:user_id] = user.id
    flash[:notice] = "ゲストユーザーとしてログインしました"
    redirect_to root_path
  end
end
