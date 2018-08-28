require "flex_commerce_api/base_resource"

module FlexCommerceApi
  module V2
    class ApiBase < FlexCommerceApi::BaseResource
      def self.endpoint_version
        "v2"
      end

      reconfigure
    end
  end
end
