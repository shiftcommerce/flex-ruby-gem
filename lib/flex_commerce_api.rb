require "flex_commerce_api/version"
require "flex_commerce_api/config"
module FlexCommerceApi
  def self.config
    FlexCommerceApi::Config.instance.tap do | config |
      yield config if block_given?
    end
  end
end

# @TODO Setup auto load for models