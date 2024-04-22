## アプリケーションの概要
パルクールをしている人たちの練習スポットを投稿・共有するアプリ。マップ機能と動画投稿機能を使う事で、具体的な場所を特定しつつ、そこで行う練習やフロー（一連の動き）をイメージさせやすくする。

アプリのURL: https://flow-spot-a3396b24d772.herokuapp.com/

![readme用スクリーンショット1](readme-1.png)

## 使用している技術
![Static Badge](https://img.shields.io/badge/HTML5-%23E34F26?style=for-the-badge&logo=HTML5&logoColor=white)
![Static Badge](https://img.shields.io/badge/CSS3-blue?style=for-the-badge&logo=CSS3)
![Static Badge](https://img.shields.io/badge/JavaScript-black?style=for-the-badge&logo=JavaScript)
![Static Badge](https://img.shields.io/badge/Ruby%20on%20Rails-%23D30001?style=for-the-badge&logo=Ruby%20on%20Rails)
![Static Badge](https://img.shields.io/badge/Ruby-%23CC342D?style=for-the-badge&logo=Ruby)
![Static Badge](https://img.shields.io/badge/Rspec-%23CC342D?style=for-the-badge)
![Static Badge](https://img.shields.io/badge/MySQL-%234479A1?style=for-the-badge&logo=MySQL&logoColor=white)
![Static Badge](https://img.shields.io/badge/PostgreSQL-%234169E1?style=for-the-badge&logo=PostgreSQL&logoColor=white)
![Static Badge](https://img.shields.io/badge/Amazon%20aws-black?style=for-the-badge&logo=Amazon%20aws)
![Static Badge](https://img.shields.io/badge/Amazon%20S3-%23569A31?style=for-the-badge&logo=Amazon%20S3&logoColor=white)
![Static Badge](https://img.shields.io/badge/Heroku-%23430098?style=for-the-badge&logo=Heroku&logoColor=white)
![Static Badge](https://img.shields.io/badge/Google%20Maps-%234285F4?style=for-the-badge&logo=Google%20Maps&logoColor=white)
![Static Badge](https://img.shields.io/badge/Gmail-%23EA4335?style=for-the-badge&logo=Gmail&logoColor=white)

## アプリケーションの機能一覧
* ユーザー機能
  * 新規登録、ログイン、ログアウト
  * ゲストログイン
  * ユーザー間のフォロー・フォロワー
  * パスワードリセット
* 投稿機能
  * 画像・動画投稿
  * google mapによる位置情報表示(google map apiを使用)
  * 投稿へのいいね
* ユーザー・投稿検索機能

## 実装したテスト内容
* systemspecによる機能テスト
* modelspecによるモデル単体テスト

## モデル全体のER図
 ![er図](erd.png)

## アプリ開発までの背景と収集情報
### 想定ユーザー
パルクールを野外で練習している10～30代男女
### 解決する課題
外でパルクールの練習をしたいが、近くに練習に適した場所が見つからない、あるいはどんな場所がいいのか分からない
### 解決方法
他の経験者が使っている練習スポットをマップで見ることが出来れば解決
### 製品
練習場所を見つけられるスポット共有アプリ

### 必要なページ
* トップページ
* アプリケーション紹介ページ
* 検索ページ
* ユーザー情報ページ
* ユーザー情報編集ページ
* お気に入りスポット一覧ページ
* 投稿詳細ページ
* 投稿情報編集ページ
* 投稿一覧ページ
* 投稿編集ページ
* 投稿詳細ページ

### 独自性（他に類似したアプリケーションがあるかどうか）
パルクールに関連したアプリケーションはまだ確認ができていないため、独自性は高い。現状としてはサイトで「おすすめスポット〇選」という名目で紹介されているのみ。また場所を紹介しているのみで、実際の動き等は参照することができない。

### 需要の高さ（そのアプリケーションを必要とする人数は多いか）
パルクールというマイナーなスポーツに特化させているため、需要は高くないと推測される。そもそもパルクールは怪我をしやすいスポーツであり、初心者にとって野外での練習はハードルが高い場合があるため、利用するユーザーが経験者に偏るる可能性あり。

## 使用方法(新規登録、ログイン)
* トップページまたはヘッダーメニューの新規登録・ログイン・ゲストログインを選択

![readme用スクリーンショット2](readme-2.png)

* 新規登録の場合

入力必須項目である名前・メールアドレス・パスワードを入力して、「新規登録する」を押す

![readme用スクリーンショット3](readme-3.png)

* ログインの場合

新規登録時に設定したメールアドレスとパスワードを入力して、「ログインする」を押す

![readme用スクリーンショット4](readme-4.png)

* ゲストログインの場合

トップページまたはヘッダーメニューのゲストログインをクリック後、通常ログイン扱いとなり、（ユーザープロフィール編集を除く）全てのサービスが通常ユーザーと同じように使用可能となる

![readme用スクリーンショット5](readme-5.png)

## 使用方法(スポット投稿)

①トップページまたはヘッダーメニューの「スポットを投稿する」または「新規スポット投稿」を押す

![readme用スクリーンショット6](readme-6.png)

②入力必須項目であるタイトル・住所を入力した上で、「登録する」を押す

![readme用スクリーンショット7](readme-7.png)

③投稿完了後、投稿一覧ページに作成した投稿が表示される

※画像を設定していない場合、デフォルトで用意されている画像が使用される

![readme用スクリーンショット8](readme-8.png)
