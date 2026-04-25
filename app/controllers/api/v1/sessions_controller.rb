module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :authenticate_api_user!, only: %i[create refresh]

      def create
        user = User.find_by(email_address: params[:email_address])

        unless user&.authenticate(params[:password])
          return render json: { error: "Invalid email or password" }, status: :unauthorized
        end

        render json: token_response(user), status: :ok
      end

      def refresh
        refresh_token = RefreshToken.find_by(token: params[:refresh_token])

        unless refresh_token&.active?
          return render json: { error: "Invalid or expired refresh token" }, status: :unauthorized
        end

        refresh_token.revoke!
        render json: token_response(refresh_token.user), status: :ok
      end
    end
  end
end
