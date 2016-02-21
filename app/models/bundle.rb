require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Bundle model
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #   # Fetch all reports, paginated
  #   FlexCommerce::Bundle.all
  #
  #   # Fetch by slug
  #   FlexCommerce::Bundle.find("slug:test")
  #
  class Bundle < FlexCommerceApi::ApiBase
    has_many :bundle_groups, class_name: "::FlexCommerce::BundleGroup"
  end
end
