# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_current_user

  def set_current_user    
    @current_user = User.find_by(id: session[:user_id])  
  end

  def authenticate_user
    return if @current_user

    flash[:alert] = "ログインが必要です"
    redirect_to "/login"
  end

  def forbid_login_user
    return unless @current_user

    flash[:alert] = "すでにログイン済みです"
    redirect_to root_path
  end

  private

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session[:user_id] = nil
  end
end
