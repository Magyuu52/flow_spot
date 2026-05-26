# frozen_string_literal: true

class HomeController < ApplicationController
  def top
    @latest_posts = Post.latest
    @most_favorited_posts = Post.most_favorited
  end

  def about; end
end
