module FlexCommerceApi
  class Config
    include Singleton
    attr_accessor :flex_root_url, :flex_api_key
    attr_reader :api_version

    def initialize
      @api_version = API_VERSION
    end

    def api_base_url
      "#{flex_root_url}/#{api_version}"
    end
  end
end