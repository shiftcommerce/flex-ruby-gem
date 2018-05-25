require 'dotenv'
Dotenv.load
require "spec_helper"
require "flex_commerce_api"
require "active_support/tagged_logging"
require "json_matchers/rspec"
root = File.expand_path("../", __dir__)
Dir[File.join root, "spec/support_e2e/**/*.rb"].sort.each { |f| require f }
# raise "API_URL, API_ACCOUNT and API_KEY must be set in your environment" unless ENV.key?("API_URL") && ENV.key?("API_ACCOUNT") && ENV.key?("API_KEY")
FlexCommerceApi.config do |config|
  config.flex_root_url = "https://shift-platform-dev-api.global.ssl.fastly.net"
  config.flex_api_key = "Mi9lMmY2MjI2M2JmOTU3NDFmYzZiMTM1NGEwMDQzNTI3NmFlZTMxMmY2YTJlMzA4OGViOGNkYjNmYWY0YmY0MGYyODQ3MGU3MWEwZGEyZGFhZjBkN2E2OGYwMGM5ZmVkNzdlNTU3ZWMzYzFhOTI4YjhiN2Q4ZWRmZWJkMDM5YWZlZTJhMTE1NDg1OTM3YjhkNTdkMmQ2OGVkNTJhYTc0NGZlNzQ1N2E2YjM3YzZmZDQxZGU1OGViMzgyMTIzMzZmN2Q4YzQzMjg5ZTFhNDU4MThkNTZkNTZiMzAxMjEyZjk5YjExNWFhNzY0NjYwYjUyOGNkYTA4M2ZiMGYwMmMwZTBi"
  config.flex_account = "testing"
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
end