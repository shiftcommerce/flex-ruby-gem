require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce template
  #
  class Template < FlexCommerceApi::ApiBase
    has_many :sections, class_name: "::FlexCommerce::Section"
  end
end
