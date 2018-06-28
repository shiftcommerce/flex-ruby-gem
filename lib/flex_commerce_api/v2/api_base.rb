require "flex_commerce_api/api_base"

module FlexCommerceApi
  module V2
    class ApiBase < FlexCommerceApi::ApiBase
      def self.endpoint_version
        "v2"
      end

      reconfigure
    end
  end
end
