# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GuestSessions", type: :request do
  describe "POST /guest_login" do
    it "ゲストユーザーとしてログインできる" do
      post guest_login_path
      expect(response).to redirect_to(root_path)
    end

    it "ゲストユーザーが作成される" do
      expect {
        post guest_login_path
      }.to change(User, :count).by(1)
    end

    context "ゲストユーザーが既に存在する場合" do
      before { create(:user, :guest) }

      it "新しいユーザーは作成されない" do
        expect {
          post guest_login_path
        }.not_to change(User, :count)
      end

      it "既存ゲストでログインできる" do
        post guest_login_path
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
