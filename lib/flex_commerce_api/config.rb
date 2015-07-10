require "singleton"
module FlexCommerceApi
  #
  # Global configuration object
  #
  # This is not accessed directly but using code similar to this example :-
  #
  #   FlexCommerceApi.config do |config|
  #     config.flex_root_url=ENV["FLEX_ROOT_URL"]
  #     config.flex_api_key=ENV["FLEX_API_KEY"]
  #   end
  #
  # The above code would typically be found in a rails initializer as an example.
  class Config
    include Singleton
    # @!attribute flex_root_url
    #  The root url for the flex server.  Must include the account name at the end
    #  For example https://api.flexcommerce.com/myaccount
    # @!attribute flex_api_key
    #  The API key to access the flex server with.  This comes from the 'Access Keys'
    #  section of the admin panel
    # @!attribute [r] api_version
    #  The API version.  This is tied to the gem version so if you want to access
    #  a later version of the API you must get a later version of the gem.
    attr_accessor :flex_root_url, :flex_api_key
    attr_reader :api_version

    def initialize
      @api_version = API_VERSION
    end

    # The api base URL
    # @return [String] The base URL for the flex system.  Calculated from the
    #  flex_root_url and _api_verision
    def api_base_url
      "#{flex_root_url}/#{api_version}"
    end
  end
end
