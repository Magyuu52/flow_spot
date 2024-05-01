require 'rails_helper'

RSpec.describe "User", type: :model do
  describe 'ユーザーのバリデーション関連' do
    it '必須項目の名前とメールアドレスとパスワードがある場合は有効であること' do
      valid_user = FactoryBot.build(:user)
      expect(valid_user).to be_valid
    end

    it 'ユーザーに名前がない場合は無効であること' do
      user_without_name = FactoryBot.build(:user, name: '')
      expect(user_without_name).to be_invalid
    end

    it 'ユーザーの名前が20文字を超える場合は無効であること' do
      user_over_name = FactoryBot.build(:user, name: 'a' * 21)
      expect(user_over_name).to be_invalid
    end

    it 'ユーザーにメールアドレスがない場合は無効であること' do
      user_without_email = FactoryBot.build(:user, email: '')
      expect(user_without_email).to be_invalid
    end

    it "ユーザーのメールアドレスに「@」がない場合は無効であること" do
      user_without_at_mark_email = FactoryBot.build(:user, email: "aaa")
      expect(user_without_at_mark_email).to be_invalid
    end

    it "ユーザーのメールアドレスに「@」が二つある場合は無効であること" do
      user_with_double_at_mark_email = FactoryBot.build(:user, email: "a@@a")
      expect(user_with_double_at_mark_email).to be_invalid
    end

    it "ユーザーのメールアドレスの途中に空白がある場合は無効であること" do
      user_with_blank_email = FactoryBot.build(:user, email: "a @a")
      expect(user_with_blank_email).to be_invalid
    end

    it  '重複したメールアドレスを持つユーザーは無効であること' do
      user = FactoryBot.create(:user)
      user_duplicate_email = FactoryBot.build(:user, email: user.email)
      expect(user_duplicate_email).to be_invalid
    end

    it 'ユーザーにパスワードがない場合は無効であること' do
      user_without_password = FactoryBot.build(:user, password: '')
      expect(user_without_password).to be_invalid
    end

    it 'ユーザーのパスワードが6文字未満の場合は無効であること' do
      user_less_letter_password = FactoryBot.build(:user, password: 'Aa111')
      expect(user_less_letter_password).to be_invalid
    end

    it 'ユーザーのパスワードが12文字を超える場合は無効であること' do
      user_over_letter_password = FactoryBot.build(:user, password: 'Aa11111111111')
      expect(user_over_letter_password).to be_invalid
    end

    it 'パスワードに英大文字が含まれない場合無効な状態であること' do
      user_without_uppercase_letter_password = FactoryBot.build(:user, password: 'aaa111')
      expect(user_without_uppercase_letter_password).to be_invalid
    end

    it 'パスワードに英小文字が含まれない場合無効な状態であること' do
      user_without_lowercase_letter_password = FactoryBot.build(:user, password: 'AAA111')
      expect(user_without_lowercase_letter_password).to be_invalid
    end

    it 'パスワードに数字が含まれない場合は無効であること' do
      user_without_numbers_password = FactoryBot.build(:user, password: 'aaaAAA')
      expect(user_without_numbers_password).to be_invalid
    end

    it 'ユーザーのパスワードと確認用パスワードが一致しない場合は無効であること' do
      user_password_not_match = FactoryBot.build(:user, password_confirm: 'not_match')
      expect(user_password_not_match).to be_invalid
    end

    it 'ユーザーの自己紹介文が100文字を超える場合は無効であること' do
      user_over_letter_introduction = FactoryBot.build(:user, introduction: 'a' * 101)
      expect(user_over_letter_introduction).to be_invalid
    end

    it 'ユーザーのアイコン画像に不適合のファイルを保存した場合は無効であること' do
      user_wrong_file_image = FactoryBot.create(:user)
      user_wrong_file_image.image = fixture_file_upload('spec/fixtures/video/test_post.mp4')
      expect(user_wrong_file_image).to be_invalid
    end

    it "ファイルサイズが5MBを超えるアイコン画像を保存した場合は無効であること" do
      post_over_filesize_image = FactoryBot.build(:user)
      post_over_filesize_image.image = fixture_file_upload("spec/fixtures/image/test_user_invalid.png")
      expect(post_over_filesize_image).to be_invalid
    end
  end

  describe 'ユーザーのアソシエーション関連' do
    let(:user) { create(:user) }
    let(:post) { create(:post, user: user) }

    it 'postモデルとの関連付け正しく設定されていること' do
      expect(user.posts).to include post
    end
  end

  describe 'ユーザーのインスタンスメソッド関連' do
    context 'フォロー機能' do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      before do
        user.follow(other_user.id)
      end
      
      it 'ユーザーをフォローすると、following?による判定がtrueになること' do
        expect(user.following?(other_user)).to eq true
      end
      
      it 'ユーザーのフォローを解除するとfollowing?による判定がfalseになること' do
        user.unfollow(other_user.id)
        expect(user.following?(other_user)).to eq false
      end
    end

    context '検索機能' do
      let(:user1) { create(:user, name: 'user1') }
      let(:user2) { create(:user, name: 'user2') }

      it '検索フォームにキーワードを入力すると、そのキーワードを持つユーザーモデルのみ取得されること' do
        expect(User.search("1")).to include user1
        expect(User.search("1")).to_not include user2
      end
    
      it '検索フォームのキーワードが未入力の場合、全てのユーザーモデルが取得されること' do
        expect(User.search("")).to include user1, user2
      end
    end
  end
end
