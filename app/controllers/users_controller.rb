# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user, {only: [:edit, :update]}
  before_action :forbid_login_user, {only: [:new, :login_form, :login]}
  before_action :ensure_correct_user, {only: [:edit, :update]}

  def index
    @users = User.all
    @users_count = @users.count
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit(:name, :email, :password, :password_confirm, :introduction))
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "ユーザーの新規登録に成功しました"
      redirect_to root_path
    else
      render "new", status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
    @user_posts_count = @user.posts.count
    @user_liked_posts = Like.where(user_id: @user.id)
    @user_liked_posts_count = @user_liked_posts.count
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @current_user.update(params.require(:user).permit(:name, :introduction, :password, :password_confirm, :experience, :image))
      flash[:notice] = "アカウント情報を更新しました"
      redirect_to action: :show
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def login_form
  end

  def login
    @user = User.find_by(email: params[:email], password: params[:password]) 
    if @user
      session[:user_id] = @user.id
      flash[:notice] = "ログインに成功しました"
      redirect_to root_path
    else
      @error_message = "メールアドレスまたはパスワードが間違っています"
      render :login_form, status: :unprocessable_entity
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "ログアウトに成功しました"
    redirect_to root_path
  end

  def search
    @searched_users = User.search(params[:keyword])
    @searched_users_count = @searched_users.where.not(id: @current_user.id).count
  end

  def ensure_correct_user
    return if @current_user.id == params[:id].to_i

    flash[:alert] = "アクセス権限がありません"
    redirect_to root_path
  end
end
