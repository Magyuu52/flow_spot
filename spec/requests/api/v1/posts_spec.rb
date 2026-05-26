# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  let(:user) { create(:user) }
  let!(:posts) { create_list(:post, 3, user: user) }

  describe 'GET /api/v1/posts' do
    context '有効なJWTトークンの場合' do
      it '投稿一覧がJSON形式で返される' do
        get api_v1_posts_path, headers: auth_header(user), as: :json
        expect(response).to have_http_status(:ok)
        expect(json_response.size).to eq(3)
      end

      it '各投稿にユーザー情報が含まれる' do
        get api_v1_posts_path, headers: auth_header(user), as: :json
        expect(json_response.first).to have_key('user')
        expect(json_response.first['user']).to have_key('name')
      end
    end

    it_behaves_like 'requires valid JWT' do
      let(:request_without_token) { get api_v1_posts_path, as: :json }
      let(:request_with_invalid_token) do
        get api_v1_posts_path, headers: { 'Authorization' => 'Bearer invalid' }, as: :json
      end
    end
  end

  describe 'GET /api/v1/posts/:id' do
    context '有効なJWTトークンの場合' do
      it '投稿詳細がJSON形式で返される' do
        get api_v1_post_path(posts.first), headers: auth_header(user), as: :json
        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(posts.first.id)
      end
    end

    context '存在しない投稿IDの場合' do
      it '404が返される' do
        get api_v1_post_path(id: 99_999), headers: auth_header(user), as: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    it_behaves_like 'requires valid JWT' do
      let(:request_without_token) { get api_v1_post_path(posts.first), as: :json }
      let(:request_with_invalid_token) do
        get api_v1_post_path(posts.first), headers: { 'Authorization' => 'Bearer invalid' }, as: :json
      end
    end
  end
end
