require 'dotenv'
Dotenv.load

require "flex_commerce_api"
require "active_support/logger"
FlexCommerceApi.config do |config|
  config.flex_root_url = ENV.fetch("API_ROOT", "http://test.flexcommerce.com")
  config.flex_api_key = ENV.fetch("API_KEY", "somerandomkeythatisprettylongevenlongerthanthat")
  config.flex_account = ENV.fetch("API_ACCOUNT", "testing")
  config.logger = nil
  config.order_test_mode = false
  config.logger = ActiveSupport::Logger.new(STDOUT)
end