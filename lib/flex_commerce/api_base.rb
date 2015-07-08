require "json_api_client"
require "faraday/request/basic_authentication"
require "uri"
module FlexCommerce
  class ApiBase < JsonApiClient::Resource
    # set the api base url in an abstract base class
    self.site = Api::API_BASE_URL
    class << self
      def username
        URI.parse(site).path.split("/").reject(&:empty?).first
      end
      def password
        ENV["FLEX_API_KEY"]
      end
    end
  end
  ApiBase.connection do |connection|
    connection.faraday.basic_auth(ApiBase.username, ApiBase.password)
  end
end
