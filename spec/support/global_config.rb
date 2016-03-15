require "flex_commerce_api"
require "active_support/logger"
FlexCommerceApi.config do |config|
  config.flex_root_url = "http://test.flexcommerce.com"
  config.flex_api_key = "somerandomkeythatisprettylongevenlongerthanthat"
  config.flex_account = "testaccount"
  config.logger = nil
  config.order_test_mode = false
  #config.logger = ActiveSupport::Logger.new(STDOUT)
end
