require "flex_commerce_api/api_base"
module FlexCommerce
  class CustomerSegment < FlexCommerceApi::ApiBase
    has_many :customer_segment_members
  end
end
