# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :authenticate_user, {except: [:index, :show]}
  before_action :ensure_correct_user, {only: [:edit, :update, :destroy]}

  SORT_SCOPES = {
    "old"            => :old,
    "most_favorited" => :most_favorited,
  }.freeze

  def index
    @posts       = sorted_posts
    @posts_count = @posts.count
  end
  
  def new
    @post = Post.new
  end

  def create
    @post = Post.new(build_post_params_with_resized_image)
    @post.user_id = @current_user.id
    @post.user_name = @current_user.name
    if @post.save
      flash[:notice] = "新規投稿の作成に成功しました"
      redirect_to :posts
    else
      render "new", status: :unprocessable_entity
    end
  end

  def show
    @post = Post.find(params[:id])
    @likes_count = Like.where(post_id: @post.id).count
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(build_post_params_with_resized_image)
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
    @searched_posts = Post.search(params[:keyword])
    @searched_posts_count = @searched_posts.count
  end

  def ensure_correct_user
    @post = Post.find(params[:id])
    return if @post.user_id == @current_user.id

    flash[:alert] = "アクセス権限がありません"
    redirect_to root_path
  end

  private

  def sorted_posts
    sort_key   = SORT_SCOPES.keys.find { |key| params[key] }
    scope_name = SORT_SCOPES.fetch(sort_key, :latest)
    Post.public_send(scope_name)
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
