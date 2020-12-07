require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::DeallocateOrder do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"

  subject { described_class.create(order_id: 1) }

  let(:headers) do 
    { 
      "Accept" => "application/vnd.api+json",
      "Content-Type" => "application/vnd.api+json"}
    }
  end

  context "when deallocating an order" do
    before do
      FlexCommerceApi.config.order_test_mode = false

      request_body = {
        data: {
          type: "deallocate_order",
          attributes: {
            order_id: 1
          }
        }
      }.to_json

      stub_request(:post, "#{api_root}/deallocate_order.json_api")
        .with(headers: headers, body: request_body)
        .to_return do |request|
        {
          status: 201,
          headers: headers,
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

    it { is_expected.to be_a(described_class) }
    it { is_expected.to have(0).errors }

    # it "does not return errors" do
    #   expect(subject).to be_a described_class
    #   expect(subject.errors).to be_empty
    # end
  end
end
