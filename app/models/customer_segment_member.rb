require "flex_commerce_api/api_base"
module FlexCommerce
  class CustomerSegmentMember < FlexCommerceApi::ApiBase
    belongs_to :customer_segment
  end
end
