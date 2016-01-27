require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Redirect model
  #
  # This model provides access to the flex commerce redirect
  #
  class Redirect < FlexCommerceApi::ApiBase
    # we only provide lookup via the gem
    def self.path(*)
      "redirects/matches"
    end

    # abstraction to ensure redirects can be loaded easily
    def self.find_by_resource(source_type: nil, source_slug: nil, source_path: )
      find({ source_type: source_type, source_slug: source_slug, source_path: source_path })
    end
  end
end
