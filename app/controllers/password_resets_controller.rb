class PasswordResetsController < ApplicationController
  def new
  end

  def create
    service = Users::PasswordResetService.new(email: params[:email])
    if service.call
      flash[:notice] = "パスワード再設定申請メールを送りました"
      redirect_to root_path
    else
      flash.now[:alert] = "メールアドレスが見つかりませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find_signed!(params[:token], purpose: "password_reset")
  end

  def update
    @user = User.find_signed!(params[:token], purpose: "password_reset")
    if @user.update(params.require(:user).permit(:password, :password_confirm))
      flash[:notice] = "パスワードが再設定されました"
      redirect_to login_path
    else
      flash.now[:alert] = "パスワードの再設定に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end
end
