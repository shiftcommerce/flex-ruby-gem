require "flex_commerce_api/base_resource"

module FlexCommerceApi
  module OMS
    class ApiBase < FlexCommerceApi::BaseResource
      def self.endpoint_version
        "v1/oms"
      end

      reconfigure
    end
  end
end
