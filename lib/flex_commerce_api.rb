require "flex_commerce_api/version"

module FlexCommerceApi
  FLEX_ROOT_URL = ENV["FLEX_ROOT_URL"]
  API_BASE_URL = "#{FLEX_ROOT_URL}/#{API_VERSION}"
end
