# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PasswordResets", type: :request do
  let(:user) { create(:user) }

  describe "GET /password/reset" do
    it "パスワードリセット申請フォームが表示される" do
      get password_reset_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /password/reset" do
    context "登録済みメールアドレスの場合" do
      it "トップページへリダイレクトされる" do
        post password_reset_path, params: { email: user.email }
        expect(response).to redirect_to(root_path)
      end
    end

    context "未登録メールアドレスの場合" do
      it "422が返される" do
        post password_reset_path, params: { email: "unknown@example.com" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /password/reset/edit" do
    context "有効なトークンの場合" do
      it "パスワード再設定フォームが表示される" do
        token = user.signed_id(purpose: "password_reset", expires_in: 15.minutes)
        get password_reset_edit_path, params: { token: token }
        expect(response).to have_http_status(:ok)
      end
    end

    context "無効なトークンの場合" do
      it "リセット申請ページへリダイレクトされる" do
        get password_reset_edit_path, params: { token: "invalid_token" }
        expect(response).to redirect_to(password_reset_path)
      end
    end
  end

  describe "PATCH /password/reset/update" do
    let(:token) { user.signed_id(purpose: "password_reset", expires_in: 15.minutes) }

    context "有効なパラメータの場合" do
      it "パスワードが更新されログインページへリダイレクトされる" do
        patch password_reset_update_path, params: {
          token: token,
          user: { password: "NewPass1", password_confirm: "NewPass1" }
        }
        expect(response).to redirect_to(login_path)
      end
    end

    context "パスワードが一致しない場合" do
      it "422が返される" do
        patch password_reset_update_path, params: {
          token: token,
          user: { password: "NewPass1", password_confirm: "Different1" }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
