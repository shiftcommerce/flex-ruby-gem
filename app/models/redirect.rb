require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Redirect model
  #
  # This model provides access to the flex commerce redirect
  #
  class Redirect < FlexCommerceApi::ApiBase

    def self.find_by_resource(source_type: nil, source_slug: nil, source_path: )
      where({type_slug_path: { source_type: source_type, source_slug: source_slug, source_path: source_path }}).first
    end
  end
end
