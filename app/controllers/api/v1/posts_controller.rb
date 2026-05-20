# frozen_string_literal: true

module Api
  module V1
    class PostsController < BaseController
      def index
        authorize Post
        posts = policy_scope(Post).includes(:user).order(created_at: :desc)
        render json: posts.map { |post| post_json(post) }
      end

      def show
        post = Post.find(params[:id])
        authorize post
        render json: post_json(post)
      rescue ActiveRecord::RecordNotFound
        render json: { error: "投稿が見つかりません" }, status: :not_found
      end

      private

      def post_json(post)
        {
          id: post.id,
          content: post.content,
          latitude: post.latitude,
          longitude: post.longitude,
          user: { id: post.user.id, name: post.user.name },
          created_at: post.created_at
        }
      end
    end
  end
end
