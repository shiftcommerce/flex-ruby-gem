require "json_api_client"
require "faraday/request/basic_authentication"
require "uri"
module FlexCommerceApi
  class ApiBase < JsonApiClient::Resource
    # set the api base url in an abstract base class
    self.site = FlexCommerceApi.config.api_base_url
    class << self
      def username
        URI.parse(site).path.split("/").reject(&:empty?).first
      end
      def password
        FlexCommerceApi.config.flex_api_key
      end
    end
  end
  ApiBase.connection do |connection|
    connection.faraday.basic_auth(ApiBase.username, ApiBase.password)
  end
end
