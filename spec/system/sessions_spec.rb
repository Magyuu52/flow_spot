require 'rails_helper'

RSpec.describe "Sessions", type: :system do
  let(:user) { create(:user) }

  describe 'ログイン' do
    context 'ユーザーの入力情報が正しい場合' do
      it 'ログインできること' do
        visit login_path
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'Test123'
        click_on 'ログインする'
        expect(current_path).to eq root_path
        expect(page).to have_content 'ログインに成功しました'
      end
    end

    context 'ユーザーの入力情報に誤りがある場合' do
      it 'ログインできないこと' do
        visit login_path
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: 'Test122'
        click_on 'ログインする'
        expect(current_path).to eq login_path
        expect(page).to have_content 'メールアドレスまたはパスワードが間違っています'
      end
    end
  end

  describe 'ログアウト' do
    it 'ユーザーがログアウトすると、トップページへリダイレクトすること' do
      login(user)
      within '.navbar' do
        click_on 'ログアウト'
      end
      expect(current_path).to eq root_path
      expect(page).to have_content 'ログアウトに成功しました'
    end
  end

  describe 'ゲストログイン' do
    it 'ゲストログインできること' do
      visit root_path
      within '.navbar' do
        click_on 'ゲストログイン'
      end
      expect(current_path).to eq root_path
      expect(page).to have_content 'ゲストユーザーとしてログインしました'
    end
  end
end
