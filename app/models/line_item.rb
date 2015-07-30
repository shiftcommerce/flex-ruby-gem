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
      def prefix_path
        "carts/%{cart_id}"
      end

      def path(params)
        container = params[:relationships][:container]
        raise "The container was not a cart or a cart hash - cannot perform this request" unless container.is_a?(FlexCommerce::Cart) || container.is_a?(Hash)
        cart_id = container.is_a?(FlexCommerce::Cart) ? container.id : container[:id]
        super params.merge(cart_id: cart_id)
      end
    end
  end
end
