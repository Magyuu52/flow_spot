# frozen_string_literal: true

class OauthSessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_or_create_from_oauth(auth)

    if user.persisted?
      log_in(user)
      redirect_to root_path, notice: "#{auth.provider} でログインしました"
    else
      redirect_to "/login", alert: "ログインに失敗しました"
    end
  end

  def failure
    redirect_to "/login", alert: "認証に失敗しました: #{params[:message]}"
  end
end
