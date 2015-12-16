require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Stock Level model
  #
  # This model provides access to the flex commerce stock level
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Fetching stock levels for specific skus
  #   FlexCommerce::StockLevel.where(skus: "sku1,sku2,sku3").all
  #
  #
  #
  class StockLevel < FlexCommerceApi::ApiBase

    class << self
      def path(params, instance = nil)
        if params[:filter] && params[:filter].key?(:skus)
          skus = params[:filter].delete(:skus)
          params.delete(:filter) if params[:filter].empty?
          "stock_levels?filter[skus]=#{skus}"
        else
          super
        end
      end

    end
  end
end
