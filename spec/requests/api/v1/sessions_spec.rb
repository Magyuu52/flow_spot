# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let(:user) { create(:user) }

  describe 'POST /api/v1/sessions' do
    context '有効な認証情報の場合' do
      it 'JWTトークンが返される' do
        post api_v1_sessions_path, params: { email: user.email, password: user.password }, as: :json
        expect(response).to have_http_status(:ok)
        expect(json_response).to have_key('token')
        expect(json_response['user']['id']).to eq(user.id)
      end
    end

    context '無効な認証情報の場合' do
      it '401が返される' do
        post api_v1_sessions_path, params: { email: user.email, password: 'wrong' }, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(json_response).to have_key('error')
      end
    end

    context '存在しないメールアドレスの場合' do
      it '401が返される' do
        post api_v1_sessions_path, params: { email: 'nobody@example.com', password: 'Test123' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
