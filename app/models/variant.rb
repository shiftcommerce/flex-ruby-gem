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
    has_many :price_entries

    def add_markdown_prices(markdown_prices)
      self.class.requestor.custom("relationships/markdown_prices", {request_method: :post}, {id: id, data: markdown_prices.map(&:as_relation)})
    end
  end
end
