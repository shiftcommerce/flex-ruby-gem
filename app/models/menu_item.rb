require "flex_commerce_api/api_base"
module FlexCommerce
  class MenuItem < FlexCommerceApi::ApiBase
    belongs_to :menu, class_name: "::FlexCommerce::Menu"
    has_many :menu_items
  end
end
