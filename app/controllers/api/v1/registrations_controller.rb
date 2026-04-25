module Api
  module V1
    class RegistrationsController < BaseController
      skip_before_action :authenticate_api_user!, only: :create

      def create
        user = User.new(registration_params)

        if user.save
          render json: token_response(user), status: :created
        else
          render json: {
            error: "Registration failed",
            errors: user.errors.as_json
          }, status: :unprocessable_entity
        end
      end

      private

      def registration_params
        params.expect(user: %i[name email_address password password_confirmation])
      end
    end
  end
end
