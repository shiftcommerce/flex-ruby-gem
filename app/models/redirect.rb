require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Redirect model
  #
  # This model provides access to the flex commerce redirect
  #
  class Redirect < FlexCommerceApi::ApiBase

    def self.find_by_path(source_path: )
      where({source_path: { source_path: source_path }}).first
    end

  end
end
