# frozen_string_literal: true

class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV.fetch("JWT_SECRET_KEY", "dev-secret-key")
  ALGORITHM = "HS256"
  DEFAULT_EXPIRATION = 24.hours

  class DecodeError < StandardError; end

  def self.encode(payload, expiration: DEFAULT_EXPIRATION)
    payload[:exp] = expiration.from_now.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    raise DecodeError, "トークンがありません" if token.blank?

    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: ALGORITHM)
    decoded.first
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    raise DecodeError, e.message
  end
end
