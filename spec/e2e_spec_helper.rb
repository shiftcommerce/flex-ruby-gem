require 'dotenv'
Dotenv.load
require "spec_helper"
require "flex_commerce_api"
require "active_support/tagged_logging"
WebMock.disable!
root = File.expand_path("../", __dir__)
Dir[File.join root, "spec/support_e2e/**/*.rb"].sort.each { |f| require f }
raise "API_URL, API_ACCOUNT and API_KEY must be set in your environment" unless ENV.key?("API_URL") && ENV.key?("API_ACCOUNT") && ENV.key?("API_KEY")
FlexCommerceApi.config do |config|
  config.flex_root_url = ENV["API_URL"]
  config.flex_account = ENV["API_ACCOUNT"]
  config.flex_api_key = ENV["API_KEY"]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
end