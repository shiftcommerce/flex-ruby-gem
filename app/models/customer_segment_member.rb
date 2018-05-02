require "flex_commerce_api/api_base"
module FlexCommerce
  class CustomerSegmentMember < FlexCommerceApi::ApiBase
    has_one :customer_segment
  end
end
