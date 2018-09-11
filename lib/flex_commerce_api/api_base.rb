require "flex_commerce_api/base_resource"

module FlexCommerceApi
  class ApiBase < BaseResource
    def self.endpoint_version
      "v1"
    end

    reconfigure
  end
end
