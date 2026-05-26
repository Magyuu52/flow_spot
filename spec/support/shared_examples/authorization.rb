# frozen_string_literal: true

RSpec.shared_examples 'requires authentication' do
  it '未ログイン時にログインページへリダイレクトされる' do
    expect(response).to redirect_to('/login')
  end
end

RSpec.shared_examples 'denies access to non-owner' do
  it '権限がなくトップページへリダイレクトされる' do
    expect(response).to redirect_to(root_path)
  end
end

RSpec.shared_examples 'forbids logged-in users' do
  it 'ログイン済みユーザーはトップページへリダイレクトされる' do
    expect(response).to redirect_to(root_path)
  end
end

RSpec.shared_examples 'returns unauthorized json' do
  it '401 Unauthorized を返す' do
    expect(response).to have_http_status(:unauthorized)
  end
end

RSpec.shared_examples 'requires valid JWT' do
  context 'トークンなしの場合' do
    it '401が返される' do
      request_without_token
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context '無効なトークンの場合' do
    it '401が返される' do
      request_with_invalid_token
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
