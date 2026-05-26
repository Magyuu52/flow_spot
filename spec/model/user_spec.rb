# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:record) { build(:user) }

  describe 'バリデーション' do
    it '必須項目が揃っている場合は有効であること' do
      expect(record).to be_valid
    end

    it_behaves_like "validates presence of", :name
    it_behaves_like "validates presence of", :email
    it_behaves_like "validates presence of", :password

    describe '名前' do
      it '20文字を超える場合は無効であること' do
        record.name = 'a' * 21
        expect(record).to be_invalid
      end
    end

    describe 'メールアドレス' do
      it '「@」がない場合は無効であること' do
        record.email = "aaa"
        expect(record).to be_invalid
      end

      it '「@」が二つある場合は無効であること' do
        record.email = "a@@a"
        expect(record).to be_invalid
      end

      it '途中に空白がある場合は無効であること' do
        record.email = "a @a"
        expect(record).to be_invalid
      end

      it '重複している場合は無効であること' do
        create(:user, email: "dup@example.com")
        record.email = "dup@example.com"
        expect(record).to be_invalid
      end
    end

    describe 'パスワード' do
      it '6文字未満の場合は無効であること' do
        record.password = 'Aa111'
        record.password_confirm = 'Aa111'
        expect(record).to be_invalid
      end

      it '12文字を超える場合は無効であること' do
        record.password = 'Aa11111111111'
        record.password_confirm = 'Aa11111111111'
        expect(record).to be_invalid
      end

      it '英大文字が含まれない場合は無効であること' do
        record.password = 'aaa111'
        record.password_confirm = 'aaa111'
        expect(record).to be_invalid
      end

      it '英小文字が含まれない場合は無効であること' do
        record.password = 'AAA111'
        record.password_confirm = 'AAA111'
        expect(record).to be_invalid
      end

      it '数字が含まれない場合は無効であること' do
        record.password = 'aaaAAA'
        record.password_confirm = 'aaaAAA'
        expect(record).to be_invalid
      end

      it '確認用パスワードと一致しない場合は無効であること' do
        record.password_confirm = 'not_match'
        expect(record).to be_invalid
      end
    end

    describe '自己紹介' do
      it '100文字を超える場合は無効であること' do
        record.introduction = 'a' * 101
        expect(record).to be_invalid
      end
    end

    describe 'アイコン画像' do
      it '不適合のファイル形式の場合は無効であること' do
        saved_user = create(:user)
        saved_user.image = fixture_file_upload('spec/fixtures/video/test_post.mp4')
        expect(saved_user).to be_invalid
      end

      it 'ファイルサイズが5MBを超える場合は無効であること' do
        record.image = fixture_file_upload("spec/fixtures/image/test_user_invalid.png")
        expect(record).to be_invalid
      end
    end
  end

  describe 'アソシエーション' do
    let(:user) { create(:user) }
    let(:post_record) { create(:post, user: user) }

    it 'postモデルとの関連付けが正しく設定されていること' do
      expect(user.posts).to include post_record
    end
  end

  describe 'インスタンスメソッド' do
    describe 'フォロー機能' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      before { user.follow(other_user.id) }

      it 'フォローするとfollowing?がtrueになること' do
        expect(user.following?(other_user)).to eq true
      end

      it 'フォロー解除するとfollowing?がfalseになること' do
        user.unfollow(other_user.id)
        expect(user.following?(other_user)).to eq false
      end
    end
  end
end
