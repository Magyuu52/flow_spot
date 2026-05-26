# frozen_string_literal: true

module Posts
  # 投稿生成ロジック（著者設定・画像リサイズ）を担う Service。
  # コントローラから生成の知識を分離することで、
  # Post の組み立て方が変わってもコントローラを修正する必要がなくなる。
  #
  # 依存性の注入:
  #   image_processor — テスト時に ImageProcessing をモック可能
  class CreateService
    attr_reader :post

    DEFAULT_IMAGE_PROCESSOR = ->(tempfile) {
      ImageProcessing::MiniMagick
        .source(tempfile)
        .resize_to_fill(1627, 1084.5)
        .call
    }

    def initialize(user:, params:, image_processor: DEFAULT_IMAGE_PROCESSOR)
      @user            = user
      @params          = params
      @image_processor = image_processor
    end

    # 組み立て済みの Post を返す（保存はしない）。
    # 保存の成否判定はコントローラが担う。
    def call
      @post = Post.new(processed_params)
      @post.assign_author(@user)
      @post
    end

    private

    def processed_params
      return @params unless @params[:spot_image]

      resized_file = @image_processor.call(@params[:spot_image].tempfile)
      @params[:spot_image].tempfile = resized_file
      @params
    end
  end
end
