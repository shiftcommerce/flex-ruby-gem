require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::V2::CreateOrder, focus: true do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context", api_version: "v2"

  context "creating a test order" do
    let(:write_headers) { { "Accept" => "application/vnd.api+json", "Content-Type" => "application/vnd.api+json" } }

    describe "when config order test mode is false" do
      before :each do
        FlexCommerceApi.config.order_test_mode = false

        stub_request(:post, "#{api_root}/create_order.json_api").with(headers: write_headers).to_return do |request|
          expect(Oj.load(request.body).with_indifferent_access).not_to include(data: hash_including(attributes: hash_including(test: true)))
          {
              body: {data: {attributes: {test: false}}}.to_json,
              status: 201,
              headers: write_headers
          }
        end
      end

      subject { described_class.create(attributes_for(:order)) }

      it "does not include test attribute on create" do
        expect(subject.test).to be false
      end
    end
  end
end
