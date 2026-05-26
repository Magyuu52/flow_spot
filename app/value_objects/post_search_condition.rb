# frozen_string_literal: true

# 投稿検索条件をカプセル化する Value Object。
# Struct を使うことで属性名が定義済みとなり、Hash と違い typo を即座に検出できる。
# freeze を付与することで不変（読み取り専用）なオブジェクトとなり、引数として渡した後に意図せず値が書き換えられる副作用を防ぐ。
PostSearchCondition = Struct.new(:keyword, :sort_key, keyword_init: true) do
  # keyword が空かどうかを問い合わせるメソッド。
  # 呼び出し側が blank? を知る必要がなくなり、条件判定の責務をここに集約する。
  def blank_keyword?
    keyword.blank?
  end

  # LIKE 検索用のパターン文字列を生成する。
  # "%#{keyword}%" の生成ロジックを一か所に閉じ込め、重複を防ぐ。
  def like_pattern
    "%#{keyword}%"
  end
end
