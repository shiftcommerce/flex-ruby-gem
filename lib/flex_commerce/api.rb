require "flex_commerce/api/version"

module FlexCommerce
  module Api
    FLEX_ROOT_URL = ENV["FLEX_ROOT_URL"]
    API_BASE_URL = "#{FLEX_ROOT_URL}/#{API_VERSION}"
  end
end
