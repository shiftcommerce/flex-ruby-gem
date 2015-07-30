require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Cart model
  #
  # This model provides access to the flex commerce cart and associated line_items.
  # This model allows you to create a cart, update its line items and delete a cart.
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Creating a cart
  #
  #   FlexCommerce::Cart.create #creates and returns a new cart ready for use
  #
  #   # Fetching its line items
  #
  #   cart.line_items
  #
  #   # Finding a cart
  #
  #   FlexCommerce::Cart.find(<<cart_id>>) # Finds the cart with this unique id
  #
  #
  class Cart < FlexCommerceApi::ApiBase
    # @method find
    # @param [String] spec
    # Finds a cart
    # @return [FlexCommerce::Cart] cart The cart
    # @raise [FlexCommerceApi::Error::NotFound] If not found

    # @method line_items
    # Provides a list of associated line_items
    # @return [FlexCommerce::LineItem[]]

    # @TODO Document other popular methods that we will support

    has_many :line_items, class_name: "::FlexCommerce::LineItem"

    # Here we override line_items to provide a proxy to the array so we can use new and create on it in the normal
    # active record way
    def line_items
      has_many_association_proxy :line_items, super, inverse_of: :container
    end

  end
end
