Geocoder.configure(
  lookup: :google,
  use_https: true,
  api_key: ENV["GOOGLE_MAP_API_KEY"],
  timeout: 10,
  units: :km,

  # Geocoder 内部で例外を握り潰さず、Post モデル側でハンドリングするために
  # タイムアウト・ソケットエラーを明示的に raise させる
  always_raise: [Timeout::Error, SocketError, Geocoder::OverQueryLimitError]
)
