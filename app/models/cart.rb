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
    has_many :discount_summaries, class_name: "::FlexCommerce::DiscountSummary"
    has_many :available_shipping_methods, class_name: "::FlexCommerceApi::ApiBase"
    has_many :available_shipping_promotions, class_name: "::FlexCommerce::Promotion"
    has_one :shipping_address, class_name: "::FlexCommerce::Address"
    has_one :billing_address, class_name: "::FlexCommerce::Address"
    has_one :shipping_method, class_name: "::FlexCommerce::ShippingMethod"
    has_one :free_shipping_promotion, class_name: "::FlexCommerce::FreeShippingPromotion"
    
    # properties
    property :line_items_count, type: :integer, default: 0
    property :total_discount, default: 0

    # Here we override line_items to provide a proxy to the array so we can use new and create on it in the normal
    # active record way
    def line_items
      has_many_association_proxy :line_items, (super || []), inverse_of: :container
    end

    def empty?
      line_items_count == 0
    end

    # Merges another cart into this one using the API
    # @param [FlexCommerce::Cart] other_cart The cart to merge from
    def merge!(other_cart)
      self.last_result_set = self.class.requestor.custom("merge", { request_method: :patch }, data: {type: "carts", attributes: { from_cart_id: other_cart.id, to_cart_id: id } } )
      mark_as_persisted!
      if updated = last_result_set.first
        self.attributes = updated.attributes
        self.relationships = updated.relationships
        clear_changes_information
      end
      self
    end

    # This method is used when true stock levels re required - potentially from an external system
    # To be used during checkout phases etc..
    # Adds errors to the line items "unit_quantity" attribute if we do not have enough
    def validate_stock!
      return if empty?
      stock_levels.each do |stock_level|
        line_items.detect { |li| li.item.sku == stock_level.id }.tap do |li|
          next if li.nil?
          error_msg = if stock_level.stock_available <= 0
                        "Out of stock"
                      elsif stock_level.stock_available < li.unit_quantity
                        "Only #{stock_level.stock_available} in stock"
                      else
                        nil
                      end
          li.errors.add(:unit_quantity, error_msg) unless error_msg.nil?
        end
      end
    end

    def self.create(*args)
      if FlexCommerceApi.config.order_test_mode
        super({test: true})
      else
        super
      end
    end

    def available_shipping_methods
      return super if relationships[:available_shipping_methods].key?("data")
      shipping_methods = get_related(:available_shipping_methods).to_a
      if shipping_methods.any? { |sm| sm.is_a?(FlexCommerce::RemoteShippingMethod) }
        shipping_method_references = shipping_methods.map(&:reference)
        # We are filtering in memory here as there will never be many shipping methods and they will almost certainly be in the cache anyway
        FlexCommerce::ShippingMethod.all.select { |shipping_method| shipping_method_references.include?(shipping_method.reference)}
      else
        shipping_methods
      end
    end


    private

    def stock_levels
      StockLevel.where(skus: line_items.map { |li| li.item.sku }.join(",")).all
    end


  end
end
