require "singleton"
module FlexCommerceApi
  #
  # Global configuration object
  #
  # This is not accessed directly but using code similar to this example :-
  #
  #   FlexCommerceApi.config do |config|
  #     config.flex_root_url=ENV["FLEX_ROOT_URL"]
  #     config.flex_account=ENV["FLEX_ACCOUNT"]
  #     config.flex_api_key=ENV["FLEX_API_KEY"]
  #     config.logger = Rails.logger
  #     config.order_test_mode = ENV.key?("ORDER_TEST_MODE")
  #   end
  #
  # The above code would typically be found in a rails initializer as an example.
  class Config
    include Singleton
    # @!attribute flex_root_url
    #  The root url for the flex server.  Must NOT include the account name at the end
    #  For example https://api.flexcommerce.com
    # @!attribute flex_account
    #  The account to be used on the flex server.
    #  For example myaccount
    # @!attribute flex_api_key
    #  The API key to access the flex server with.  This comes from the 'Access Keys'
    #  section of the admin panel
    # @!attribute order_test_mode
    #  The order test mode.This config determines if orders are processed as test or real orders
    attr_accessor :flex_root_url, :flex_api_key, :flex_account, :logger, :adapter, :order_test_mode, :http_cache, :open_timeout, :timeout

    def initialize
      self.order_test_mode = false
      self.http_cache = {}
      self.open_timeout = ENV.fetch('SHIFT_OPEN_TIMEOUT', 2).to_i
      self.timeout = ENV.fetch('SHIFT_TIMEOUT', 15).to_i
    end

    # The api base URL
    # @return [String] The base URL for the flex system.  Calculated from the
    #  flex_root_url and _api_verision
    def api_base_url
      "#{flex_root_url}/#{flex_account}"
    end

    # Informs all models that the configuration may have changed
    # but only if ApiBase is defined - else nothing has loaded yet
    # so they wont need reconfiguring
    def reconfigure_all!
      FlexCommerceApi::ApiBase.reconfigure_all if FlexCommerceApi.const_defined? "ApiBase"
    end

  end
end
