# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Like, type: :model do
  let(:user) { create(:user) }
  let(:post_record) { create(:post, user: user) }
  let(:record) { create(:like, post_id: post_record.id, user_id: user.id) }

  describe 'バリデーション' do
    it '必要なパラメーターが揃っていれば有効であること' do
      expect(record).to be_valid
    end

    it_behaves_like "requires belongs_to association", :user
    it_behaves_like "requires belongs_to association", :post
  end

  describe 'データの一意性' do
    let(:other_post) { create(:post, user: user) }
    let(:other_user) { create(:user) }

    before { record }

    it '同じ投稿に連続でいいねをできないこと' do
      invalid_like = build(:like, post_id: post_record.id, user_id: user.id)
      expect(invalid_like).to be_invalid
    end

    it 'いいねされた投稿が同じでも、いいねしたユーザーが異なる場合は有効であること' do
      like_same_post = create(:like, post_id: post_record.id, user_id: other_user.id)
      expect(like_same_post).to be_valid
    end

    it 'いいねされた投稿が異なる場合、いいねしたユーザーが同じでも有効であること' do
      like_same_user = create(:like, post_id: other_post.id, user_id: user.id)
      expect(like_same_user).to be_valid
    end
  end
end
