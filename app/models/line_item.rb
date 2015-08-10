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
        "carts/%{cart_id}"
      end

      def path(params, record)
        #@TODO Change to suit polymorphic requirement for future
        new_params = record.nil? ? params : params.merge(path: {cart_id: record.relationships.container["data"]["id"]})
        super new_params
      end
    end

    def save(*args)
      # This is required as at the moment (1.0.0.beta6) only changed relations are saved
      # it is not ideal as it is changing the state of the resource
      # @TODO Check this is still required
      relationships.set_all_attributes_dirty
      super
    end
  end
end
