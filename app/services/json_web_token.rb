class JsonWebToken
  SECRET = Rails.application.credentials.jwt_secret!
  DEFAULT_ACCESS_TOKEN_EXPIRY = 30.minutes
  ALGORITHM = "HS256"

  class << self
    def encode_access_token(user_id, expires_at = DEFAULT_ACCESS_TOKEN_EXPIRY.from_now)
      jti = SecureRandom.uuid
      payload = {
        user_id: user_id,
        jti: jti,
        iat: Time.current.to_i,
        exp: expires_at.to_i,
        token_type: "access"
      }
      JWT.encode(payload, SECRET, ALGORITHM)
    end

    def decode(token)
      payload = JWT.decode(token, SECRET, true, { algorithm: ALGORITHM }).first
      HashWithIndifferentAccess.new(payload)
    rescue JWT::ExpiredSignature
      raise ExpiredTokenError
    rescue JWT::DecodeError
      raise InvalidTokenError
    end
  end

  class ExpiredTokenError < StandardError; end
  class InvalidTokenError < StandardError; end
end
