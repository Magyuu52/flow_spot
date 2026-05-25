# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "GET /users" do
    it "ユーザー一覧が正常に表示される" do
      get users_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users/:id" do
    it "ユーザー詳細が正常に表示される" do
      get user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users/new" do
    context "未ログインの場合" do
      it "新規登録フォームが表示される" do
        get new_user_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログイン済みの場合" do
      include_context "authenticated request"
      before { get new_user_path }

      it_behaves_like "forbids logged-in users"
    end
  end

  describe "POST /users" do
    let(:valid_params) do
      {
        user: {
          name: "新規ユーザー",
          email: "new_user@example.com",
          password: "Test123",
          password_confirm: "Test123"
        }
      }
    end

    context "有効なパラメータの場合" do
      it "ユーザーが作成される" do
        expect {
          post users_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "作成後にトップページへリダイレクトされる" do
        post users_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it "セッションにuser_idが保存される（自動ログイン）" do
        post users_path, params: valid_params
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end
    end

    context "無効なパラメータの場合" do
      it "ユーザーが作成されない" do
        expect {
          post users_path, params: { user: { name: "", email: "", password: "" } }
        }.not_to change(User, :count)
      end

      it "422が返される" do
        post users_path, params: { user: { name: "", email: "", password: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /users/:id/edit" do
    context "本人の場合" do
      include_context "authenticated request"

      it "編集フォームが表示される" do
        get edit_user_path(user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他のユーザーの場合" do
      include_context "authenticated as other user"
      before { get edit_user_path(user) }

      it_behaves_like "denies access to non-owner"
    end

    context "未ログインの場合" do
      before { get edit_user_path(user) }

      it_behaves_like "requires authentication"
    end
  end

  describe "PATCH /users/:id" do
    context "本人の場合" do
      include_context "authenticated request"

      it "プロフィールが更新される" do
        patch user_path(user), params: { user: { name: "更新名前" } }
        expect(user.reload.name).to eq("更新名前")
      end

      it "更新後にユーザー詳細へリダイレクトされる" do
        patch user_path(user), params: { user: { name: "更新名前" } }
        expect(response).to redirect_to(user_path(user))
      end
    end

    context "他のユーザーの場合" do
      include_context "authenticated as other user"

      it "更新が拒否される" do
        patch user_path(user), params: { user: { name: "不正更新" } }
        expect(user.reload.name).not_to eq("不正更新")
      end
    end
  end

  describe "GET /login" do
    context "未ログインの場合" do
      it "ログインフォームが表示される" do
        get login_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログイン済みの場合" do
      include_context "authenticated request"
      before { get login_path }

      it_behaves_like "forbids logged-in users"
    end
  end

  describe "POST /login" do
    context "有効な認証情報の場合" do
      it "ログインに成功しトップページへリダイレクトされる" do
        post login_path, params: { email: user.email, password: user.password }
        expect(response).to redirect_to(root_path)
      end
    end

    context "無効な認証情報の場合" do
      it "ログインに失敗し422が返される" do
        post login_path, params: { email: user.email, password: "wrong" }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /logout" do
    include_context "authenticated request"

    it "ログアウトに成功しトップページへリダイレクトされる" do
      post logout_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /users/search" do
    it "ユーザー検索が正常に表示される" do
      get search_users_path, params: { q: { name_cont: "test" } }
      expect(response).to have_http_status(:ok)
    end
  end
end
