# test/integration/api/v1/sessions_test.rb

require "openapi_helper"

class Api::V1::SessionsTest < Miniswag::TestCase
  path "/api/v1/sessions" do
    post "Sign in" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          email_address: { type: :string },
          password: { type: :string }
        },
        required: %w[email_address password],
        examples: {
          valid: {
            summary: "Valid credentials",
            value: { email_address: "api_user@example.com", password: "password123456" }
          },
          invalid: {
            summary: "Invalid credentials",
            value: { email_address: "api_user@example.com", password: "wrongpassword" }
          }
        }
      }

      response 200, "successful sign in" do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                token: { type: :string },
                refresh_token: { type: :string },
                expires_at: { type: :string, format: "date-time" }
              }
            }
          }
        params { { body: { email_address: "api_user@example.com", password: "password123456" } } }
        run_test!
      end

      response 401, "invalid credentials" do
        schema type: :object,
          properties: { error: { type: :string } }
        params { { body: { email_address: "api_user@example.com", password: "wrongpassword" } } }
        run_test!
      end
    end
  end

  path "/api/v1/sessions/refresh" do
    post "Refresh token" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          refresh_token: { type: :string }
        },
        required: %w[refresh_token],
        examples: {
          valid: {
            summary: "Valid refresh token",
            value: { refresh_token: "ActiveToken123" }
          },
          invalid: {
            summary: "Invalid or expired refresh token",
            value: { refresh_token: "expiredtoken" }
          }
        }
      }

      response 200, "token refreshed" do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                token: { type: :string },
                refresh_token: { type: :string },
                expires_at: { type: :string, format: "date-time" }
              }
            }
          }
        params { { body: { refresh_token: "ActiveToken123" } } }
        run_test!
      end

      response 401, "invalid or expired refresh token" do
        schema type: :object,
          properties: { error: { type: :string } }
        params { { body: { refresh_token: "expiredtoken" } } }
        run_test!
      end
    end
  end
end
