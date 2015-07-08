require "flex_commerce_api/version"
require "flex_commerce_api/config"
module FlexCommerceApi
  def self.config
    FlexCommerceApi::Config.instance.tap do | config |
      yield config if block_given?
    end
  end
  def self.gem_root
    File.expand_path("../", __dir__)
  end

  autoload :Product, File.join(gem_root, "app", "models", "product")
end

# @TODO Setup auto load for models
