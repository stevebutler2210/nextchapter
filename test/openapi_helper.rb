# frozen_string_literal: true

require "test_helper"

require "miniswag"
require "miniswag/test_case"

Miniswag.configure do |config|
  # Root folder where OpenAPI spec files will be generated
  config.openapi_root = Rails.root.join("docs/api").to_s

  config.openapi_format = :yaml

  config.openapi_specs = {
    "v1/openapi.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "NextChapter API",
        version: "v1",
        description: "JSON API for the NextChapter mobile companion app"
      },
      servers: [
        { url: "http://localhost:3000", description: "Development" },
        { url: "https://nextchapter.fly.dev", description: "Production" }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT"
          }
        }
      },
      security: [ { bearer_auth: [] } ]
    }
  }
end
