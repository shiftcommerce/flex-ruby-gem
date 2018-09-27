require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce LineItem model
  #
  # This model provides access to the flex commerce cart's line_items.
  # This model allows you to create a line_item, update its contents, delete a line_item or list the line items for a specific cart.
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Creating a line item for a specific cart
  #
  #   FlexCommerce::LineItem.create container: cart, item: variant, unit_quantity: 3 #creates and returns a new line item ready for use
  #
  class LineItem < FlexCommerceApi::ApiBase

    # @method item
    # The item (either a variant or a bundle)
    # @return [FlexCommerce::Variant|FlexCommerce::Bundle]

    # @TODO Document other popular methods that we will support

    has_one :item
    belongs_to :cart, class_name: "::FlexCommerce::Cart"

    class << self
      def _prefix_path
        ""
      end
    end

    # note: only embedded in order responses, not carts
    has_many :line_item_discounts, class_name: "::FlexCommerce::LineItemDiscount"
  end
end
