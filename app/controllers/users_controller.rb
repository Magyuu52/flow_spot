# frozen_string_literal: true

class UsersController < ApplicationController
  include OwnerAuthorizable

  before_action :authenticate_user, {only: [:edit, :update]}
  before_action :forbid_login_user, {only: [:new, :login_form, :login]}
  before_action :ensure_correct_user, {only: [:edit, :update]}

  def index
    @users = User.includes(image_attachment: :blob)
    @users_count = @users.count
  end

  def new
    @user = User.new
  end

  def create
    service = Users::RegistrationService.new(params: registration_params)
    @user   = service.user
    if service.call
      log_in(@user)
      flash[:notice] = "ユーザーの新規登録に成功しました"
      redirect_to root_path
    else
      render "new", status: :unprocessable_entity
    end
  end

  def show
    @user                   = User.find(params[:id])
    @user_posts_count       = @user.posts.count
    @user_liked_posts       = @user.liked_posts
    @user_liked_posts_count = @user_liked_posts.count
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(profile_params)
      flash[:notice] = "アカウント情報を更新しました"
      redirect_to user_path(@user)
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def login_form
  end

  def login
    service = Users::AuthenticationService.new(email: params[:email], password: params[:password])
    if service.call
      log_in(service.user)
      flash[:notice] = "ログインに成功しました"
      redirect_to root_path
    else
      @error_message = "メールアドレスまたはパスワードが間違っています"
      render :login_form, status: :unprocessable_entity
    end
  end

  def logout
    log_out
    flash[:notice] = "ログアウトに成功しました"
    redirect_to root_path
  end

  def search
    @searched_users       = User.search(params[:keyword])
    @searched_users_count = @searched_users.where.not(id: @current_user.id).count
  end

  private

  def ensure_owner?
    @current_user.id == params[:id].to_i
  end

  def registration_params
    params.require(:user).permit(:name, :email, :password, :password_confirm, :introduction)
  end

  def profile_params
    params.require(:user).permit(:name, :introduction, :password, :password_confirm, :experience, :image)
  end
end
