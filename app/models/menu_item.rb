require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce menu item model
  #
  # This model is used by the Menu model as an association so is not
  # usable directly on the API as there is no corresponding URL.
  #
  # Each menu item has many menu items (i.e. nested) which are generally
  # all loaded up front, so this should be a relatively inexpensive operation
  # in order to build a menu system on the front end application.
  #
  #
  class MenuItem < FlexCommerceApi::ApiBase
    belongs_to :menu, class_name: "::FlexCommerce::Menu"
    has_many :menu_items
  end
end
