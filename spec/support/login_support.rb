module LoginSupport
  def login(user)
    visit login_path
    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: 'Test123'
    click_on 'ログインする'
  end
end
