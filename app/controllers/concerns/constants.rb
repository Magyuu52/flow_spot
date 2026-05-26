# frozen_string_literal: true

module Constants
  # Integer はRuby組み込みのimmutableオブジェクトのためfreezeは不要
  GUEST_USER_ID = 1

  # String はミュータブルなため破壊的変更を防ぐためfreezeが必要
  GUEST_NAME  = 'ゲストユーザー'
  GUEST_EMAIL = 'guest@example.com'

  # Array・Hashも同様にfreezeで外部からの変更（<<等）を防ぐ
  VALID_SORT_KEYS = %w[latest old most_favorited].freeze

  VALID_EXPERIENCE_OPTIONS = [
    '設定しない', '〜3ヶ月', '3〜6ヶ月', '6〜9ヶ月',
    '9ヶ月〜1年', '1〜2年', '2〜3年', '3年以上'
  ].freeze
end
