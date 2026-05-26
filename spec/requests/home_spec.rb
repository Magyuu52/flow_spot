# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /' do
    it 'トップページが正常に表示される' do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /about' do
    it 'Aboutページが正常に表示される' do
      get about_path
      expect(response).to have_http_status(:ok)
    end
  end
end
