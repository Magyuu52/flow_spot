# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:post_record) { create(:post, user: user) }

  describe 'GET /posts' do
    before { create_list(:post, 3, user: user) }

    it '投稿一覧が正常に表示される' do
      get posts_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /posts/:id' do
    it '投稿詳細が正常に表示される' do
      get post_path(post_record)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /posts/search' do
    it '検索結果が正常に表示される' do
      get search_posts_path, params: { q: { title_cont: 'test' } }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /posts/new' do
    context 'ログイン済みの場合' do
      include_context 'authenticated request'

      it '新規投稿フォームが表示される' do
        get new_post_path
        expect(response).to have_http_status(:ok)
      end
    end

    context '未ログインの場合' do
      before { get new_post_path }

      it_behaves_like 'requires authentication'
    end
  end

  describe 'POST /posts' do
    let(:valid_params) do
      {
        post: {
          title: 'テスト投稿',
          address: '東京都渋谷区1-1-1',
          content: 'テスト内容',
          spot_image: Rack::Test::UploadedFile.new(
            Rails.root.join('spec/fixtures/image/test_post.jpg'), 'image/jpeg'
          )
        }
      }
    end

    context 'ログイン済みの場合' do
      include_context 'authenticated request'

      it '有効なパラメータで投稿が作成される' do
        expect do
          post posts_path, params: valid_params
        end.to change(Post, :count).by(1)
      end

      it '作成後に投稿一覧へリダイレクトされる' do
        post posts_path, params: valid_params
        expect(response).to redirect_to(posts_path)
      end

      it '無効なパラメータでは作成されない' do
        expect do
          post posts_path, params: { post: { title: '', address: '', content: '' } }
        end.not_to change(Post, :count)
      end

      it '無効なパラメータで422が返される' do
        post posts_path, params: { post: { title: '', address: '', content: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context '未ログインの場合' do
      before { post posts_path, params: valid_params }

      it_behaves_like 'requires authentication'
    end
  end

  describe 'GET /posts/:id/edit' do
    context '投稿者本人の場合' do
      include_context 'authenticated request'

      it '編集フォームが表示される' do
        get edit_post_path(post_record)
        expect(response).to have_http_status(:ok)
      end
    end

    context '他のユーザーの場合' do
      include_context 'authenticated as other user'
      before { get edit_post_path(post_record) }

      it_behaves_like 'denies access to non-owner'
    end

    context '未ログインの場合' do
      before { get edit_post_path(post_record) }

      it_behaves_like 'requires authentication'
    end
  end

  describe 'PATCH /posts/:id' do
    let(:update_params) { { post: { title: '更新タイトル' } } }

    context '投稿者本人の場合' do
      include_context 'authenticated request'

      it '投稿が更新される' do
        patch post_path(post_record), params: update_params
        expect(post_record.reload.title).to eq('更新タイトル')
      end

      it '更新後に投稿一覧へリダイレクトされる' do
        patch post_path(post_record), params: update_params
        expect(response).to redirect_to(posts_path)
      end
    end

    context '他のユーザーの場合' do
      include_context 'authenticated as other user'
      before { patch post_path(post_record), params: update_params }

      it_behaves_like 'denies access to non-owner'
    end
  end

  describe 'DELETE /posts/:id' do
    context '投稿者本人の場合' do
      include_context 'authenticated request'

      it '投稿が削除される' do
        delete post_path(post_record)
        expect(Post.find_by(id: post_record.id)).to be_nil
      end

      it '削除後に投稿一覧へリダイレクトされる' do
        delete post_path(post_record)
        expect(response).to redirect_to(posts_path)
      end
    end

    context '他のユーザーの場合' do
      include_context 'authenticated as other user'

      it '削除が拒否される' do
        post_record
        expect do
          delete post_path(post_record)
        end.not_to change(Post, :count)
      end
    end
  end
end
