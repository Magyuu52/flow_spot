# frozen_string_literal: true

namespace :posts do
  desc "住所未登録の投稿をバッチジオコーディング（Thread + Mutex）"
  task geocode_batch: :environment do
    posts   = Post.where(latitude: nil).to_a
    mutex   = Mutex.new
    updated = []

    threads = posts.each_slice(10).map do |batch|
      Thread.new do
        batch.each do |post|
          post.geocode
          post.save(validate: false)
          mutex.synchronize { updated << post.id }
        end
      end
    end
    threads.each(&:join)
    puts "更新件数: #{updated.size}"
  end
end
