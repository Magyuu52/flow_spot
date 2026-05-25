# frozen_string_literal: true

RSpec.shared_examples "requires authentication" do
  it "未ログイン時にログインページへリダイレクトされる" do
    expect(response).to redirect_to("/login")
  end
end

RSpec.shared_examples "returns unauthorized json" do
  it "401 Unauthorized を返す" do
    expect(response).to have_http_status(:unauthorized)
  end
end
