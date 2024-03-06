class PostsController < ApplicationController
  def index
    @posts = Post.where(user_id: @current_user.id)
  end
  
  def new
    @post = Post.new
  end

  def create
    @post = Post.new(params.require(:post).permit(:title, :spot_name, :address, :content, :spot_image, :flow_video))
    @post.user_id = @current_user.id
    if @post.save
      flash[:notice] = "新規投稿の作成に成功しました"
      redirect_to :posts
    else
      render "new"
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
    if @post.update(params.require(:post).permit(:title, :spot_name, :address, :content, :spot_image, :flow_video))
      flash[:notice] = "「#{@post.title}」の情報を更新しました"
      redirect_to :posts
    else
      render "edit"
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    flash[:notice] = "「#{@post.title}」を削除しました"
    redirect_to :posts
  end

  def search
    @posts = Post.search(params[:keyword])
  end
end
