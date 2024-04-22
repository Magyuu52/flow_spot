require 'rails_helper'

RSpec.describe Like, type: :model do
  describe 'データの保存機能' do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }
    let(:like) { create(:like, post_id: post.id, user_id: user.id) }

    it 'likeモデルに必要なパラメーターが揃っていれば有効であること' do
      expect(like).to be_valid
    end

    it 'likeモデルのいいねしたユーザーのidがnilの場合は無効であること' do
      like.user_id = nil
      expect(like).to be_invalid
    end

    it 'likeモデルのいいねされた投稿のidがnilの場合は無効であること' do
      like.post_id = nil
      expect(like).to be_invalid
    end
  end

  describe 'データの一意性' do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }
    let(:other_post) { create(:post, user: user) }
    let(:other_user) { create(:user) }
    let!(:like) { create(:like, post_id: post.id, user_id: user.id) }

    it '同じ投稿に連続でいいねをできないこと' do
      invalid_like = FactoryBot.build(:like, post_id: post.id, user_id: user.id)
      expect(invalid_like).to be_invalid
    end

    it 'いいねされた投稿が同じでも、いいねしたユーザーが異なる場合は有効であること' do
      like_same_post = FactoryBot.create(:like, post_id: post.id, user_id: other_user.id)
      expect(like_same_post).to be_valid
    end

    it 'いいねされた投稿が異なる場合、いいねしたユーザーが異なる場合は有効であること' do
      like_same_user = FactoryBot.create(:like, post_id: other_post.id, user_id: user.id)
      expect(like_same_user).to be_valid
    end
  end
end