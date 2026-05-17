# frozen_string_literal: true

class PostsController < ApplicationController
  include OwnerAuthorizable

  before_action :authenticate_user, {except: [:index, :show]}
  before_action :ensure_correct_user, {only: [:edit, :update, :destroy]}

  # Duck Typing: 各値は「call(scope) に応答できる」ことだけを保証する。
  # 呼び出し側（sorted_posts）はオブジェクトの種別を知らず、call するだけでよい。
  SORT_STRATEGIES = {
    "old"            => Posts::SortStrategies::Old.new,
    "most_favorited" => Posts::SortStrategies::MostFavorited.new,
  }.freeze

  def index
    @posts       = sorted_posts
    @posts_count = @posts.count
  end
  
  def new
    @post = Post.new
  end

  def create
    service = Posts::CreateService.new(user: @current_user, params: post_params)
    @post   = service.call
    if @post.save
      flash[:notice] = "新規投稿の作成に成功しました"
      redirect_to :posts
    else
      render "new", status: :unprocessable_entity
    end
  end

  def show
    @post        = Post.find(params[:id])
    @likes_count = @post.likes_count
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post   = Post.find(params[:id])
    service = Posts::UpdateService.new(post: @post, params: post_params)
    if service.call
      flash[:notice] = "「#{@post.title}」の情報を更新しました"
      redirect_to :posts
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    flash[:notice] = "「#{@post.title}」を削除しました"
    redirect_to :posts
  end

  def search
    condition             = PostSearchCondition.new(keyword: params[:keyword]).freeze
    @searched_posts       = Post.search(condition)
    @searched_posts_count = @searched_posts.count
  end

  private

  def ensure_owner?
    @post = Post.find(params[:id])
    @post.user_id == @current_user.id
  end

  def sorted_posts
    sort_key = SORT_STRATEGIES.keys.find { |key| params[key] }
    strategy = SORT_STRATEGIES.fetch(sort_key, Posts::SortStrategies::Latest.new)
    base = Post.includes(:user, :likes, :spot_image_attachment,
                         user: { image_attachment: :blob })
    Post.with_filter { |posts| strategy.call(posts.merge(base)) }
  end

  def post_params
    params.require(:post).permit(:title, :address, :content, :spot_image, :flow_video)
  end

  # spot_image が添付されている場合のみリサイズ済みパラメータを返す
  # 引数の post_params を直接書き換えず、tempfile のみ差し替えた形で返す
  def build_post_params_with_resized_image
    return post_params unless post_params[:spot_image]

    resized_file = resize_image(post_params[:spot_image].tempfile)
    post_params[:spot_image].tempfile = resized_file
    post_params
  end

  def resize_image(tempfile)
    ImageProcessing::MiniMagick
      .source(tempfile)
      .resize_to_fill(1627, 1084.5)
      .call
  end
end
