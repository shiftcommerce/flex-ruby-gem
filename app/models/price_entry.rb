require "flex_commerce_api/api_base"

module FlexCommerce
  class PriceEntry < FlexCommerceApi::ApiBase
    belongs_to :variant

      property :variant_reference
      property :starts_at
      property :ends_at
      property :was_price
      property :current_price
      property :created_at
      property :updated_at
  end
end
