# frozen_string_literal: true

# Google Maps API に対する HTTP クライアント。
# ベースURL・認証情報・接続設定を一元管理し、
# タイムアウトと一時的エラーへのリトライ（exponential backoff）を提供する。
#
# 利用例:
#   client = GoogleMapsClient.new
#   result = client.geocode("東京都渋谷区")
#   result[:lat]  # => 35.6617773
#   result[:lng]  # => 139.7040587
class GoogleMapsClient
  BASE_URL    = "https://maps.googleapis.com"
  MAX_RETRIES = 3

  RETRYABLE_EXCEPTIONS = [
    Faraday::TimeoutError,
    Faraday::ConnectionFailed,
    Faraday::ServerError
  ].freeze

  class ApiError < StandardError; end
  class GeocodeError < ApiError; end

  def initialize(api_key: ENV.fetch("GOOGLE_MAP_API_KEY"))
    @api_key    = api_key
    @connection = build_connection
  end

  def geocode(address)
    response = with_retry do
      @connection.get("/maps/api/geocode/json", address: address, key: @api_key)
    end

    parse_geocode_response(response)
  end

  private

  def build_connection
    Faraday.new(url: BASE_URL) do |f|
      f.options.open_timeout = 3
      f.options.timeout      = 10
      f.response :raise_error
      f.adapter  Faraday.default_adapter
    end
  end

  # 一時的なエラー（タイムアウト・接続失敗・5xx）に対して最大 MAX_RETRIES 回リトライする。
  # 待機時間は exponential backoff（2^n 秒）で増加させ、相手サーバーへの負荷集中を避ける。
  def with_retry
    attempts = 0
    begin
      attempts += 1
      yield
    rescue *RETRYABLE_EXCEPTIONS => e
      raise ApiError, "#{MAX_RETRIES} 回リトライしましたが失敗しました: #{e.message}" if attempts >= MAX_RETRIES

      wait_time = 2**attempts
      Rails.logger.warn("[GoogleMapsClient] Attempt #{attempts} failed: #{e.message}, retrying in #{wait_time}s")
      sleep(wait_time)
      retry
    end
  end

  def parse_geocode_response(response)
    body   = JSON.parse(response.body)
    status = body["status"]

    unless status == "OK"
      raise GeocodeError, "Geocoding failed with status: #{status}"
    end

    location = body.dig("results", 0, "geometry", "location")
    { lat: location["lat"], lng: location["lng"] }
  end
end
