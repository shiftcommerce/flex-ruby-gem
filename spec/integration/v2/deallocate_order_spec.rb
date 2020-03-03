require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::V2::DeallocateOrder do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context", api_version: "v2"

  context "deallocating an order" do
    let(:write_headers) { {"Accept" => "application/vnd.api+json", "Content-Type" => "application/vnd.api+json"} }

    describe "when deallocating an order" do
      before :each do
        FlexCommerceApi.config.order_test_mode = false

        request_body = {
          data: {
            type: "deallocate_order",
            attributes: {
              order_id: 1
            }
          }
        }.to_json

        stub_request(:post, "#{api_root}/deallocate_order.json_api").with(headers: write_headers, body: request_body).to_return do |request|
          {
            status: 201,
            headers: write_headers,
            body: {
              data: {
                id: "1",
                type: "deallocate_order",
                attributes: {
                  order_id: 1
                }
              }
            }.to_json
          }
        end
      end

      subject { described_class.create(order_id: 1) }

      it "does not include test attribute on create" do
        expect(subject).to be_a described_class
      end
    end
  end
end
