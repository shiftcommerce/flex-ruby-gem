require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Menu model
  #
  # This model provides access to the flex commerce menus.
  # As managing the menus is the job of the administration panel, this
  # model is read only.
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Fetching all menus
  #
  #   FlexCommerce::Menu.all #fetches all menus(actually the first page in case there are thousands)
  #
  #   # Finding a specific menu
  #
  #   FlexCommerce::Menu.find("my-menu-reference") # Finds the menu with this unique id
  #
  #   # Finding nested menu items of the menu (See MenuItem class for what you can do with this including getting nested menu items)
  #
  #   FlexCommerce::Menu.find("my-product-slug").menu_items
  #
  #
  class Menu < FlexCommerceApi::ApiBase
    has_many :menu_items
    # This model has a path attribute so path can no longer be used to modify the path
    def self.path(params = nil, record = nil)
      super(params.nil? ? nil : params.except("path"), record)
    end
  end
end