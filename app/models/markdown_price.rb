require "flex_commerce_api/api_base"

module FlexCommerce
  class MarkdownPrice < FlexCommerceApi::ApiBase
    belongs_to :variant

    def active?
      Time.now.between?(start_at, end_at)
    end
  end
end
