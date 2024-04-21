require 'rails_helper'

RSpec.describe "Posts", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:post) { create(:post, user: user) }
  let!(:other_post) { create(:post, user: other_user) }
  let!(:liked_post) { create(:post, user: other_user) }
  let!(:like) { create(:like, post: liked_post, user: user) }

  describe '投稿一覧' do
    before do
      login(user)
    end

    it '自分が作成した投稿が閲覧できること' do
      visit posts_path
      expect(page).to have_content post.title
      expect(page).to have_content post.address
      expect(page).to have_content post.user.name
    end

    it '他のユーザーが作成した投稿が閲覧できること' do
      visit posts_path
      expect(page).to have_content other_post.title
      expect(page).to have_content other_post.address
      expect(page).to have_content other_post.user.name
    end
  end
  
  describe '新規投稿作成機能' do
    it '新規投稿の作成ができること' do
      login(user)
      visit new_post_path
      fill_in '投稿タイトル', with: "test-post"
      fill_in '住所', with: "大阪府大阪市港区海岸通１丁目１"
      attach_file 'post[spot_image]', "spec/fixtures/image/test_post.jpg"
      click_on '投稿する'
      expect(current_path).to eq posts_path
      expect(page).to have_content '新規投稿の作成に成功しました'
      expect(page).to have_content other_post.user.name
      expect(page).to have_content post.title
    end
  end

  describe '投稿詳細ページ' do
    it '投稿の詳細画面が閲覧でき、投稿の情報が正しく表示されていること' do
      visit post_path(post.id)
      expect(current_path).to eq "/posts/#{post.id}"
      expect(page).to have_content post.title
      expect(page).to have_content post.address
      expect(page).to have_content post.user.name
    end
  end

  describe '投稿編集・更新機能' do
    before do
      login(user)
    end

    it '自分の投稿に編集ボタンが表示されること' do
      visit post_path(post.id)
      within ".post-details-top" do
        expect(page).to have_link '編集'
      end
    end

    it '他のユーザーの投稿には編集ボタンが表示されないこと' do
      visit post_path(other_post.id)
      within ".post-details-top" do
        expect(page).to_not have_link '編集'
      end
    end

    it '投稿を更新できること' do
      visit edit_post_path(post.id)
      fill_in '投稿タイトル', with: "test-post-updated"
      fill_in '住所', with: "東京都千代田区神田和泉町１−３００"
      attach_file 'post[spot_image]', "spec/fixtures/image/test_post_update.jpg"
      click_on '更新する'
      expect(current_path).to eq posts_path
      expect(page).to have_content '「test-post-updated」の情報を更新しました'
    end
  end

  describe '投稿削除機能' do
    before do
      login(user)
    end

    it '自分の投稿に削除ボタンが表示されること' do
      visit post_path(post.id)
      within ".post-details-top" do
        expect(page).to have_link '削除'
      end
    end

    it '他のユーザーの投稿には削除ボタンが表示されないこと' do
      visit post_path(other_post.id)
      within ".post-details-top" do
        expect(page).to_not have_link '削除'
      end
    end

    it '投稿を削除できること' do
      visit post_path(post.id)
      click_on '削除'
      expect(current_path).to eq posts_path
      expect(page).to have_content "「#{post.title}」を削除しました"
    end
  end

  describe 'いいね機能' do
    before do
      login(user)
    end

    context 'いいねをしていない投稿の場合' do
      it 'いいねボタンが表示されていること' do
        visit post_path(other_post.id)
        expect(page).to have_link 'いいねする'
      end

      it 'いいねができること' do
        visit post_path(other_post.id)
        click_on 'いいねする'
        expect(page).to have_link 'いいね済み'
        expect(other_post.likes.count).to eq(1)
      end
    end

    context 'いいねをしている投稿の場合' do
      it 'いいねを解除するボタンが表示されていること' do
        visit post_path(liked_post.id)
        expect(page).to have_link 'いいね済み'
      end
    
      it 'いいねを解除できること' do
        visit post_path(liked_post.id)
        click_on 'いいね済み'
        expect(page).to have_link 'いいねする'
        expect(liked_post.likes.count).to eq(0)
      end
    end
  end
end
