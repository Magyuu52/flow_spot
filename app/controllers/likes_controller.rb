# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :authenticate_user

  def create
    @like = Like.new(user_id: @current_user.id, post_id: params[:post_id])
    authorize @like
    @like.save
    respond_to do |format|
      format.html { redirect_to request.referer }
      format.json { render json: { likes_count: @like.post.likes_count, liked: true } }
    end
  end

  def destroy
    @like = Like.find_by(user_id: @current_user.id, post_id: params[:post_id])
    authorize @like
    @like.destroy
    post = Post.find(params[:post_id])
    respond_to do |format|
      format.html { redirect_to request.referer }
      format.json { render json: { likes_count: post.likes_count, liked: false } }
    end
  end
end