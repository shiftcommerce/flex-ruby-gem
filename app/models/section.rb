require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce section
  #
  class Section < FlexCommerceApi::ApiBase
    has_many :components, class_name: "::FlexCommerce::Component"
  end
end
