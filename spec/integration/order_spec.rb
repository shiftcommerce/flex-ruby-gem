require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::Order, focus: true do

  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"

  context "test order" do

    let(:resource_identifier) { build(:json_api_resource, build_resource: :order_from_fixture, base_path: base_path) }
    let(:singular_resource) { build(:json_api_top_singular_resource, data: resource_identifier) }

    let(:write_headers) { { "Accept" => "application/vnd.api+json", "Content-Type" => "application/vnd.api+json" } }

    describe "when ORDER_TEST_MODE ENV is present" do

      before :each do

        # stub_request(:post, "#{api_root}/orders.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers

        stub_request(:post, "#{api_root}/orders.json_api").with(headers: { "Accept" => "application/vnd.api+json" }) do |request|
          expect(Oj.load(request.body)).to have_attributes(data: hash_including(attributes: hash_including(test: true)))
        end

        # stub_request(:get, "#{api_root}/orders.json_api").with(headers: { "Accept" => "application/vnd.api+json" }) do |request|
        #   binding.pry
        #   expect(Oj.load(request.body)).to have_attributes(data: hash_including(attributes: hash_including(test: true)))
        #   # {body: singular_resource.to_h.to_json, status: response_status, headers: default_headers}
        # end
        # stub_request(:post, "#{api_root}/orders.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
        #
        # stub_request(:post, "#{api_root}/orders.json_api").with(headers: { "Accept" => "application/vnd.api+json" }) do |request|
        #   expect(Oj.load(request.body)).to have_attributes(data: hash_including(attributes: hash_including(test: true)))
        # end

      end

      # subject { described_class.create(cart_attributes) }
      subject { described_class.create(attributes_for(:order)) }

      it "should return with the resource" do
        expect(subject).to be_a(described_class)
      end

      it "includes test attribute on create" do
        application_config = FlexCommerceApi::Config
        allow(application_config).to receive(:order_test_mode) { true }
        order = described_class.create(attributes_for(:order))

        expect(order.test).to eq(true)
      end

    end

  end

end