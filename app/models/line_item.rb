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
    belongs_to :container

    class << self
      def _prefix_path
        ""
      end
    end

    def validate_stock!
      error_msg = if stock_available_level <= 0
                    "Out of stock"
                  elsif stock_available_level < unit_quantity
                    "Only #{stock_available_level} in stock"
                  end
      errors.add(:unit_quantity, error_msg) unless error_msg.nil?
    end
  end
end
