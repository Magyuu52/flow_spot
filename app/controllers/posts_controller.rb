class PostsController < ApplicationController
  before_action :authenticate_user, {except: [:index, :show]}
  before_action :ensure_correct_user, {only: [:edit, :update, :destroy]}

  def index
    @posts = Post.latest
    if params[:old]
      @posts = Post.old
    elsif params[:most_favorited]
      @posts = Post.most_favorited
    else
      @posts = Post.latest
    end
    @posts_count = @posts.count
  end
  
  def new
    @post = Post.new
  end

  def create
    @post = Post.new(image_resize(post_params))
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
    if @post.update(image_resize(post_params))
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
    if @post.user_id != @current_user.id
      flash[:alret] = "アクセス権限がありません"
      redirect_to root_path
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :address, :content, :spot_image, :flow_video)
  end

  def image_resize(params)
    if params[:spot_image]
      params[:spot_image].tempfile = ImageProcessing::MiniMagick.source(params[:spot_image].tempfile).resize_to_fill(1627, 1084.5).call
    end
    params
  end
end
