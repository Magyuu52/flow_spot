# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Relationships", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:referer_headers) { { "HTTP_REFERER" => user_path(other_user) } }

  describe "POST /users/:user_id/relationships" do
    context "ログイン済みの場合" do
      include_context "authenticated request"

      it "フォロー関係が作成される" do
        expect {
          post user_relationships_path(other_user), headers: referer_headers
        }.to change(Relationship, :count).by(1)
      end

      it "リファラーへリダイレクトされる" do
        post user_relationships_path(other_user), headers: referer_headers
        expect(response).to redirect_to(user_path(other_user))
      end
    end

    context "未ログインの場合" do
      before { post user_relationships_path(other_user) }

      it_behaves_like "requires authentication"
    end
  end

  describe "DELETE /users/:user_id/relationships" do
    before { user.follow(other_user.id) }

    context "ログイン済みの場合" do
      include_context "authenticated request"

      it "フォロー関係が削除される" do
        expect {
          delete user_relationships_path(other_user), headers: referer_headers
        }.to change(Relationship, :count).by(-1)
      end
    end

    context "未ログインの場合" do
      before { delete user_relationships_path(other_user) }

      it_behaves_like "requires authentication"
    end
  end

  describe "GET /users/:user_id/followings" do
    it "フォロー一覧が正常に表示される" do
      get user_followings_path(user)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /users/:user_id/followers" do
    it "フォロワー一覧が正常に表示される" do
      get user_followers_path(user)
      expect(response).to have_http_status(:ok)
    end
  end
end
