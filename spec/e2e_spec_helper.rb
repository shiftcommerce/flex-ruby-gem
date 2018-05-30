require 'dotenv'
Dotenv.load
require "spec_helper"
require "flex_commerce_api"
require "active_support/tagged_logging"
require "json_matchers/rspec"
root = File.expand_path("../", __dir__)
Dir[File.join root, "spec/support_e2e/**/*.rb"].sort.each { |f| require f }
raise "FLEX_URL, FLEX_ACCOUNT and FLEX_KEY must be set in your environment" unless ENV.key?("FLEX_URL") && ENV.key?("FLEX_ACCOUNT") && ENV.key?("FLEX_KEY")
FlexCommerceApi.config do |config|
  config.flex_root_url = ENV["FLEX_URL"]
  config.flex_account = ENV["FLEX_ACCOUNT"]
  config.flex_api_key = ENV["FLEX_KEY"]
  config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
end