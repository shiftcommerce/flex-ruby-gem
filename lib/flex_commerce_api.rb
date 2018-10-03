require "patches"
require "paypal_express"
require "flex_commerce_api/config"
require "flex_commerce"
require "flex_commerce_api/errors"
require "flex_commerce_api/json_api_client_extension/parse_json"

module FlexCommerceApi
  def self.config
    FlexCommerceApi::Config.instance.tap do |config|
      yield config if block_given?
      config.reconfigure_all! if block_given?
    end
  end
  def self.gem_root
    File.expand_path("../", __dir__)
  end
  def self.logger
    FlexCommerceApi::Config.instance.logger
  end
end
