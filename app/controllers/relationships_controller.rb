# frozen_string_literal: true

class RelationshipsController < ApplicationController
  before_action :authenticate_user, only: [:create, :destroy]

  def create
    authorize Relationship
    @current_user.follow(params[:user_id])
    redirect_to request.referer
  end

  def destroy
    authorize Relationship
    @current_user.unfollow(params[:user_id])
    redirect_to request.referer
  end

  def followings
    authorize Relationship
    user = User.find(params[:user_id])
    @users = user.followings.includes([image_attachment: :blob])
  end

  def followers
    authorize Relationship
    user = User.find(params[:user_id])
    @users = user.followers.includes([image_attachment: :blob])
  end
end
