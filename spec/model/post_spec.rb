# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  let(:record) { build(:post, user: user) }

  describe 'バリデーション' do
    it '必須項目が揃っている場合は有効であること' do
      saved = create(:post, user: user)
      expect(saved).to be_valid
    end

    it_behaves_like 'validates presence of', :title
    it_behaves_like 'validates presence of', :address

    describe 'タイトル' do
      it '30文字を超える場合は無効であること' do
        record.title = 'a' * 31
        expect(record).to be_invalid
      end
    end

    describe '内容' do
      it '500文字を超える場合は無効であること' do
        record.content = 'a' * 501
        expect(record).to be_invalid
      end
    end

    describe 'スポット画像' do
      it '不適合のファイル形式の場合は無効であること' do
        post_record = create(:post, user: user)
        post_record.spot_image = fixture_file_upload('spec/fixtures/video/test_post.mp4')
        expect(post_record).to be_invalid
      end
    end

    describe 'フロー動画' do
      it '不適合のファイル形式の場合は無効であること' do
        post_record = create(:post, user: user)
        post_record.flow_video = fixture_file_upload('spec/fixtures/image/test_post.jpg')
        expect(post_record).to be_invalid
      end

      it 'ファイルサイズが50MBを超える場合は無効であること' do
        record.flow_video = fixture_file_upload('spec/fixtures/video/test_post_invalid.mp4')
        expect(record).to be_invalid
      end
    end
  end

  describe 'アソシエーション' do
    let(:post_record) { create(:post, user: user) }
    let!(:like) { create(:like, post: post_record, user: user) }

    it 'userモデルとの関連付けが正しく設定されていること' do
      expect(user.posts).to include post_record
    end

    it 'likeモデルとの関連付けが正しく設定されていること' do
      expect(post_record.likes).to include like
    end
  end

  describe 'インスタンスメソッド' do
    describe 'いいね機能' do
      let(:post_record) { create(:post, user: user) }
      let(:other_user) { create(:user) }
      let!(:like) { create(:like, post: post_record, user: other_user) }

      it 'いいねされている場合、liked?がtrueになること' do
        expect(post_record.liked?(other_user)).to eq true
      end

      it 'いいねされていない場合、liked?がfalseになること' do
        unliked_post = create(:post, user: user)
        expect(unliked_post.liked?(other_user)).to eq false
      end
    end
  end
end
