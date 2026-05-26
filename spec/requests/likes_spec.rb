# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Likes', type: :request do
  let(:user) { create(:user) }
  let(:post_record) { create(:post) }
  let(:referer_headers) { { 'HTTP_REFERER' => post_path(post_record) } }

  describe 'POST /posts/:post_id/likes' do
    context 'ログイン済みの場合' do
      include_context 'authenticated request'

      it 'いいねが作成される' do
        expect do
          post post_likes_path(post_record), headers: referer_headers
        end.to change(Like, :count).by(1)
      end

      it 'リファラーへリダイレクトされる' do
        post post_likes_path(post_record), headers: referer_headers
        expect(response).to redirect_to(post_path(post_record))
      end

      context 'JSON形式でリクエストした場合' do
        it 'いいね数とlikedステータスが返される' do
          post post_likes_path(post_record), as: :json
          expect(json_response).to include('likes_count' => 1, 'liked' => true)
        end
      end
    end

    context '未ログインの場合' do
      before { post post_likes_path(post_record) }

      it_behaves_like 'requires authentication'
    end
  end

  describe 'DELETE /posts/:post_id/likes' do
    before { create(:like, user: user, post: post_record) }

    context 'ログイン済みの場合' do
      include_context 'authenticated request'

      it 'いいねが削除される' do
        expect do
          delete post_likes_path(post_record), headers: referer_headers
        end.to change(Like, :count).by(-1)
      end

      context 'JSON形式でリクエストした場合' do
        it 'いいね数とlikedステータスが返される' do
          delete post_likes_path(post_record), as: :json
          expect(json_response).to include('likes_count' => 0, 'liked' => false)
        end
      end
    end

    context '未ログインの場合' do
      before { delete post_likes_path(post_record) }

      it_behaves_like 'requires authentication'
    end
  end
end
