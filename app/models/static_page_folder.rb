require "flex_commerce_api/api_base"
module FlexCommerce
  class StaticPageFolder < FlexCommerceApi::ApiBase
    has_many :static_pages, class_name: "::FlexCommerce::StaticPage"
  end
end
