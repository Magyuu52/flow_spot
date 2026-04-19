class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:email])

    unless @user
      flash.now[:alert] = "メールアドレスが見つかりませんでした"
      render :new, status: :unprocessable_entity
      return
    end

    PasswordResetMailer.with(user: @user).reset.deliver_later
    flash[:notice] = "パスワード再設定申請メールを送りました"
    redirect_to root_path
  end

  def edit
    @user = User.find_signed!(params[:token], purpose: "password_reset")
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alret] = "URLの有効期限が切れています。もう一度申請をお願いします"
      redirect_to password_reset_path
  end

  def update
    @user = User.find_signed!(params[:token], purpose: "password_reset")
    if @user.update(params.require(:user).permit(:password, :password_confirm))
      flash[:notice] = "パスワードが再設定されました"
      redirect_to login_path
    else
      flash.now[:alret] = "パスワードの再設定に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end
end
