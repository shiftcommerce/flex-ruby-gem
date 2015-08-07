require "flex_commerce_api/version"
require "flex_commerce_api/config"
require "flex_commerce"
require "flex_commerce_api/errors"
module FlexCommerceApi
  def self.config
    FlexCommerceApi::Config.instance.tap do |config|
      yield config if block_given?
    end
  end
  def self.gem_root
    File.expand_path("../", __dir__)
  end
end
