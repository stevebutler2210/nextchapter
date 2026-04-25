# test/integration/api/v1/clubs_test.rb

require "openapi_helper"

class Api::V1::ClubsTest < Miniswag::TestCase
  def auth_header
    user = users(:api_user)
    expires_at = 30.minutes.from_now
    token = JsonWebToken.encode_access_token(user.id, expires_at)
    { "Authorization" => "Bearer #{token}" }
  end

  path "/api/v1/clubs" do
    get "List clubs" do
      tags "Clubs"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :Authorization,
        in: :header,
        type: :string,
        required: true,
        description: "Bearer token"

      response 200, "clubs listed" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  description: { type: :string },
                  role: { type: :string },
                  current_cycle: { type: :object, nullable: true }
                }
              }
            }
          }
        params { auth_header }
        run_test!
      end

      response 401, "missing or invalid token" do
        schema type: :object,
          properties: { error: { type: :string } }
        run_test!
      end
    end
  end

  path "/api/v1/clubs/{id}" do
    get "Get club" do
      tags "Clubs"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :Authorization,
        in: :header,
        type: :string,
        required: true,
        description: "Bearer token"

      response 200, "club found" do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                description: { type: :string },
                role: { type: :string },
                members: { type: :array },
                current_cycle: { type: :object, nullable: true }
              }
            }
          }
        params { { id: clubs(:one).id }.merge(auth_header) }
        run_test!
      end

      response 401, "missing or invalid token" do
        schema type: :object,
          properties: { error: { type: :string } }
        params { { id: clubs(:one).id } }
        run_test!
      end

      response 404, "club not found or not a member" do
        schema type: :object,
          properties: { error: { type: :string } }
        params { { id: clubs(:two).id }.merge(auth_header) }
        run_test!
      end
    end
  end
end
