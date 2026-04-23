# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_current_user

  rescue_from AuthenticationError,  with: :handle_authentication_error
  rescue_from AuthorizationError,   with: :handle_authorization_error
  rescue_from GuestOperationError,  with: :handle_guest_operation_error
  rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :handle_invalid_token

  def set_current_user
    @current_user = User.find_by(id: session[:user_id])
  end

  def authenticate_user
    raise AuthenticationError unless @current_user
  end

  def forbid_login_user
    return unless @current_user

    flash[:alert] = "すでにログイン済みです"
    redirect_to root_path
  end

  private

  def handle_authentication_error
    flash[:alert] = "ログインが必要です"
    redirect_to "/login"
  end

  def handle_authorization_error
    flash[:alert] = "アクセス権限がありません"
    redirect_to root_path
  end

  def handle_guest_operation_error
    flash[:alert] = "ゲストユーザーはこの操作を行えません"
    redirect_to root_path
  end

  def handle_invalid_token
    flash[:alert] = "URLの有効期限が切れています。もう一度申請をお願いします"
    redirect_to password_reset_path
  end

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session[:user_id] = nil
  end
end
