require "spec_helper"
require "flex_commerce_api"
require "flex_commerce_api/json_api_client_extension/forwarded_for_middleware"

describe FlexCommerceApi::JsonApiClientExtension::ForwardedForMiddleware do
  it "appends a header with the configured lambda value" do
    FlexCommerceApi.config do |config|
      config.forwarded_for = -> { "127.0.0.1" }
    end

    stub_request(:get, "http://example.com/login").to_return(
      status: 200
    )

    connection = Faraday.new { |conn|
      conn.use FlexCommerceApi::JsonApiClientExtension::ForwardedForMiddleware
      conn.adapter Faraday.default_adapter
    }

    response = connection.get("http://example.com/login")
    expect(response.env.request_headers).to include({"X-Forwarded-For": "127.0.0.1"})
  end
end
