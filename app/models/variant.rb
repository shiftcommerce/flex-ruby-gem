require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce variant model
  #
  # This model is used by the Product model as an association so is not
  # usable directly on the API as there is no corresponding URL
  #
  #
  class Variant < FlexCommerceApi::ApiBase
    has_one :product
    has_many :asset_files
    has_many :markdown_prices

    def current_price
      if markdown = markdown_prices.find(&:active?)
        markdown.price
      else
        price
      end
    end
  end
end
