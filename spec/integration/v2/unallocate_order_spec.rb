require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::V2::UnallocateOrder do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context", api_version: "v2"

  context "unallocating an order" do
    let(:write_headers) { { "Accept" => "application/vnd.api+json", "Content-Type" => "application/vnd.api+json" } }

    describe "when unallocating an order" do
      before :each do
        FlexCommerceApi.config.order_test_mode = false

        request_body = {
          data: {
            type: "unallocate_order",
            attributes: {
              order_id: 1
            }
          }
        }.to_json

        stub_request(:post, "#{api_root}/unallocate_order.json_api").with(headers: write_headers, body: request_body).to_return do |request|
          {
              status: 201,
              headers: write_headers,
              body: {
                data: {
                  id: "1",
                  type: "unallocate_order",
                  attributes: {
                    order_id: 1
                  }
                }
              }.to_json
          }
        end
      end

      subject { described_class.create(order_id: 1) }

      it "does not return errors" do
        expect(subject).to be_a described_class
        expect(subject.errors).to be_empty
      end
    end
  end
end
