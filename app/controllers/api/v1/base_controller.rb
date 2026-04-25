module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!

      private

      def authenticate_api_user!
        token = extract_token_from_header
        return render_unauthorized("No token provided") unless token

        payload = JsonWebToken.decode(token)
        return render_unauthorized("Invalid token type") unless payload[:token_type] == "access"

        user = User.find_by(id: payload[:user_id])
        return render_unauthorized("User not found") unless user

        @current_user = user
      rescue JsonWebToken::ExpiredTokenError
        render_unauthorized("Token has expired")
      rescue JsonWebToken::InvalidTokenError
        render_unauthorized("Invalid token")
      end

      def current_user
        @current_user
      end

      def extract_token_from_header
        header = request.headers["Authorization"]
        header&.split(" ")&.last
      end

      def render_unauthorized(message = "Unauthorized")
        render json: { error: message }, status: :unauthorized
      end

      def token_response(user)
        new_refresh_token = user.refresh_tokens.create!(
          expires_at: 30.days.from_now
        )

        access_token_expires_at = 30.minutes.from_now

        {
          data: {
            token: JsonWebToken.encode_access_token(user.id, access_token_expires_at),
            refresh_token: new_refresh_token.token,
            expires_at: access_token_expires_at.iso8601
          }
        }
      end
    end
  end
end
