# test/integration/api/v1/registrations_test.rb

require "openapi_helper"

class Api::V1::RegistrationsTest < Miniswag::TestCase
  path "/api/v1/registrations" do
    post "Sign up" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string },
              email_address: { type: :string },
              password: { type: :string },
              password_confirmation: { type: :string }
            },
            required: %w[name email_address password password_confirmation]
          }
        },
        examples: {
          valid: {
            summary: "Valid registration",
            value: {
              user: {
                name: "New User",
                email_address: "newuser@example.com",
                password: "password123456",
                password_confirmation: "password123456"
              }
            }
          },
          invalid: {
            summary: "Missing required fields",
            value: {
              user: {
                name: "",
                email_address: "bad",
                password: "short",
                password_confirmation: ""
              }
            }
          }
        }
      }

      response 201, "user created" do
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
        params do
          {
            body: {
              user: {
                name: "New User",
                email_address: "newuser@example.com",
                password: "password123456",
                password_confirmation: "password123456"
              }
            }
          }
        end
        run_test!
      end

      response 422, "validation failed" do
        schema type: :object,
          properties: {
            error: { type: :string },
            errors: { type: :object }
          }
        params do
          {
            body: {
              user: {
                name: "",
                email_address: "bad",
                password: "short",
                password_confirmation: ""
              }
            }
          }
        end
        run_test!
      end
    end
  end
end
