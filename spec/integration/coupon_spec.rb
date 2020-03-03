require "spec_helper"
require "flex_commerce_api"
RSpec.describe FlexCommerce::Coupon do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { FlexCommerce::Coupon }
  context "creating" do
    let(:coupon_attributes) { attributes_for(:coupon) }
    let(:expected_headers) { {"Accept" => "application/vnd.api+json"} }
    let(:expected_body) do
      {
        "data": {
          "type": "coupons",
          "attributes": {
            "coupon_code": coupon_attributes[:coupon_code]
          }
        }
      }
    end
    let(:coupon_response) do
      {
        data: {
          id: "1",
          type: "coupons",
          attributes: {
            coupon_code: coupon_attributes[:coupon_code],
            name: coupon_attributes[:name]
          }
        }
      }
    end
    let!(:stub) { stub_request(:post, "#{api_root}/carts/1/coupons.json_api").with(headers: expected_headers, body: expected_body).to_return body: coupon_response.to_json, status: response_status, headers: default_headers }
    it "should create a coupon" do
      coupon = subject_class.create(coupon_code: coupon_attributes[:coupon_code], path: {cart_id: 1})
      expect(coupon).to be_a(subject_class)
    end
  end
  context "deleting" do
    it "should destroy a coupon"
  end
end
