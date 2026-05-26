# frozen_string_literal: true

module Posts
  # 投稿一覧のソート戦略をオブジェクトとして表現するモジュール。
  #
  # Duck Typing の設計:
  #   各クラスは「call(scope) を受け取ってスコープを返す」というインターフェースだけを守る。
  #   クラス名・継承関係は問わず、call に応答できれば呼び出し側はそのまま扱える。
  #
  # 新しいソート条件を追加するとき:
  #   このファイルに新しいクラスを追加し、PostsController::SORT_STRATEGIES に登録するだけでよい。
  #   コントローラの分岐ロジックには一切触れない。
  module SortStrategies
    class Latest
      def call(scope) = scope.latest
    end

    class Old
      def call(scope) = scope.old
    end

    class MostFavorited
      def call(scope) = scope.most_favorited
    end
  end
end
