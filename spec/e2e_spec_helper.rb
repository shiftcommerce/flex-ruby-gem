require "dotenv"
Dotenv.load
require "spec_helper"
require "flex_commerce_api"
require "active_support/tagged_logging"
require "json_matchers/rspec"
root = File.expand_path("../", __dir__)
Dir[File.join root, "spec/support_e2e/**/*.rb"].sort.each { |f| require f }
raise "API_ROOT, API_ACCOUNT and API_KEY must be set in your environment" unless ENV.key?("API_ROOT") && ENV.key?("API_ACCOUNT") && ENV.key?("API_KEY")
FlexCommerceApi.config do |config|
  config.flex_root_url = ENV["API_ROOT"]
  config.flex_account = ENV["API_ACCOUNT"]
  config.flex_api_key = ENV["API_KEY"]

  # Paypal Secrets
  config.paypal_login = ENV.fetch("PAYPAL_LOGIN")
  config.paypal_password = ENV.fetch("PAYPAL_PASSWORD")
  config.paypal_signature = ENV.fetch("PAYPAL_SIGNATURE")
  config.order_test_mode = ENV.fetch("ORDER_TEST_MODE", "true")

  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
end
