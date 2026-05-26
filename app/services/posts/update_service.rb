# frozen_string_literal: true

module Posts
  # 投稿更新ロジック（画像リサイズ）を担う Service。
  # CreateService と同じ image_processor を注入できるため、
  # テスト時にリサイズ処理をスキップした軽量なモックへ差し替えられる。
  #
  # 依存性の注入:
  #   image_processor — テスト時に ImageProcessing をモック可能
  class UpdateService
    DEFAULT_IMAGE_PROCESSOR = Posts::CreateService::DEFAULT_IMAGE_PROCESSOR

    def initialize(post:, params:, image_processor: DEFAULT_IMAGE_PROCESSOR)
      @post            = post
      @params          = params
      @image_processor = image_processor
    end

    # 更新の成否を真偽値で返す
    def call
      @post.update(processed_params)
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
