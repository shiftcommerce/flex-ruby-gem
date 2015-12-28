require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe "Shopping Cart" do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::Cart }
  let(:address_class) { ::FlexCommerce::Address }
  let(:shipping_method_class) { ::FlexCommerce::ShippingMethod }
  let(:variant_class) { ::FlexCommerce::Variant }
  let(:line_item_class) { ::FlexCommerce::LineItem }
  let(:discount_summary_class) { ::FlexCommerce::DiscountSummary }
  let(:coupon_class) { ::FlexCommerce::Coupon }

  context "with fixture files from flex" do
    context "a single cart" do
      let(:singular_resource) { build(:cart_from_fixture) }
      let(:line_item_resources) do
        singular_resource.data.relationships.line_items.data.map do |ri|
          singular_resource.included.detect {|r| r.id == ri.id && r.type == ri.type}
        end
      end
      let(:discount_summary_resources) do
        singular_resource.data.relationships.discount_summaries.data.map do |ri|
          singular_resource.included.detect {|r| r.id == ri.id && r.type == ri.type}
        end
      end
      context "creating a new cart" do
        before(:each) do
          stub_request(:post, "#{api_root}/carts.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_json, status: response_status, headers: default_headers
        end
        subject { subject_class.create }
        it_should_behave_like "a singular resource with an error response"
        it "should be a cart" do
          expect(subject).to be_a(subject_class)
        end
      end
      context "fetching a single cart" do
        before :each do
          stub_request(:get, "#{api_root}/carts/1.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_json, status: response_status, headers: default_headers
        end
        subject { subject_class.find(1) }
        it_should_behave_like "a singular resource with an error response"
        it "should return the correct top level object" do
          expect(subject).to be_a(subject_class)
        end
        context "using the empty? method" do
          it "should return false with the fixture data" do
            expect(subject).not_to be_empty
          end
        end
        context "using the merge! method and passing a cart" do
          let(:other_cart) { build(:cart, id: 2) }
          let(:merged_result) { build(:cart_merged_from_fixture) }
          before(:each) do
            stub_request(:patch, "#{api_root}/carts/merge.json_api").with(body: { data: { type: "carts", attributes: { to_cart_id: subject.id, from_cart_id: other_cart.id } } }, headers: { "Accept" => "application/vnd.api+json", "Content-Type" => "application/vnd.api+json" }).to_return(body: merged_result.to_json, status: response_status, headers: default_headers)
          end
          it "should request that another cart is merged into this one" do
            subject.merge!(other_cart)
            expect(subject.line_items.count).to eql 4
          end
        end
        context "the discount_summaries association" do
          it "should fetch a list of discount summaries" do
            subject.discount_summaries.tap do |summaries|
              expect(summaries.length).to eql discount_summary_resources.length
              summaries.each_with_index do |summary, idx|
                expect(summary).to be_a(discount_summary_class)
              end
            end
          end
        end
        context "using the line items association" do
          it "should return a list of line items" do
            subject.line_items.tap do |line_items|
              expect(line_items.length).to eql line_item_resources.length
              line_items.each_with_index do |line_item, idx|
                expect(line_item).to be_a(line_item_class)
              end
            end
          end
          it "should return non empty line items" do
            expect(subject.line_items.empty?).to be false
          end
          it "should return a list of line items with the correct attributes" do
            subject.line_items.tap do |line_items|
              expect(line_items.length).to eql line_item_resources.length
              line_items.each_with_index do |line_item, idx|
                line_item_resource = line_item_resources[idx]
                line_item_resource.attributes.each_pair do |attr, value|
                  expect(line_item.send(attr)).to eql value
                end
              end
            end
          end
          it "should return a list of line items with the correct container" do
            pending "at the moment, polymorphism isnt supported so this test will fail"
            subject.line_items.tap do |line_items|
              expect(line_items.length).to eql line_item_resources.length
              line_items.each_with_index do |line_item, idx|
                expect(line_item.container).to be_a(subject_class)
              end
            end
          end
          it "should return a list of line items with the correct item" do
            subject.line_items.tap do |line_items|
              expect(line_items.length).to eql line_item_resources.length
              line_items.each_with_index do |line_item, idx|
                expect(line_item.item).to be_a(variant_class)
              end
            end
          end
          context "creating a line item with a prepared variant" do
            before(:each) do
              stub_request(:post, "#{api_root}/line_items.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return do |request|
                expect(request.body).to be_valid_json_for_schema("line_item")
                {body: line_item_resource.to_json, status: response_status, headers: default_headers}
              end
            end
            let(:variant) { variant_class.new id: "1", price: 15.50, title: "A variant"}
            let(:line_item_resource) { build(:line_item_from_fixture) }
            it "should create a line item when requested using the line_items collection on the cart - using save" do
              # @TODO We should not have to specify the cart id
              line_item = subject.line_items.new(item_id: variant.id, item_type: "Variant")
              line_item.save
              expect(line_item).to be_a(line_item_class)
            end
            it "should create a line item when requested using the line_items collection on the cart - using create" do
              line_item = subject.line_items.create(item_id: variant.id, item_type: "Variant")
              expect(line_item).to be_a(line_item_class)
            end
            it "should create a line item when requested using only the cart id" do
              line_item = line_item_class.new(relationships: {item: variant, container: subject_class.new(id: "1")})
              line_item.save
              expect(line_item).to be_a(line_item_class)
            end
          end
        end
        context "using the pull_updates! method" do
          let!(:stub) { stub_request(:patch, "#{api_root}/carts/1/pull_updates.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers }
          subject { subject_class.find(1).pull_updates! }
          it "should return a valid cart" do
            expect(subject).to be_a(subject_class)
          end
        end
        context "using the validate_stock! method" do
          let!(:stub) { stub_request(:get, "#{api_root}/stock_levels.json_api").with(headers: {"Accept" => "application/vnd.api+json"}, query: {filter: { skus: "742207266-0-1,742207266-0-2"}}).to_return body: stock_level_list.to_json, status: response_status, headers: default_headers }
          context "with no stock" do
            let(:stock_level_list) { {
              data: [
                {
                  id: "742207266-0-1",
                  type: "stock_levels",
                  attributes: {
                    stock_available: 0
                  }
                },
                {
                  id: "742207266-0-2",
                  type: "stock_levels",
                  attributes: {
                    stock_available: 10
                  }
                }
              ]
            } }
            it "should mark any line items that are out of stock" do
              subject.validate_stock!
              expect(subject.line_items[0].errors[:unit_quantity]).to include "Out of stock"
            end

          end
          context "with not enough stock" do
            let(:stock_level_list) { {
              data: [
                {
                  id: "742207266-0-1",
                  type: "stock_levels",
                  attributes: {
                    stock_available: 1
                  }
                },
                {
                  id: "742207266-0-2",
                  type: "stock_levels",
                  attributes: {
                    stock_available: 10
                  }
                }
              ]
            } }
            it "should mark any line items that are out of stock" do
              subject.validate_stock!
              expect(subject.line_items[0].errors[:unit_quantity]).to include "Only 1 in stock"
            end

          end

        end
      end
    end
    context "a single cart during checkout with addresses and shipping method" do
      let(:singular_resource) { build(:cart_from_fixture_with_checkout) }
      let(:billing_address_resource) { singular_resource.included.detect { |r| r.to_h.slice(:id, :type) == singular_resource.data.relationships.billing_address.data.to_h } }
      let(:shipping_address_resource) { singular_resource.included.detect { |r| r.to_h.slice(:id, :type) == singular_resource.data.relationships.shipping_address.data.to_h } }
      let(:shipping_method_resource) { singular_resource.included.detect { |r| r.to_h.slice(:id, :type) == singular_resource.data.relationships.shipping_method.data.to_h } }
      before :each do
        stub_request(:get, "#{api_root}/carts/1.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_json, status: response_status, headers: default_headers
      end
      subject { subject_class.find(1) }
      it_should_behave_like "a singular resource with an error response"
      it "should return the correct top level object" do
        expect(subject).to be_a(subject_class)
      end

      it "should fetch the billing address" do
        expect(subject.billing_address).to be_a(address_class)
        expect(subject.billing_address.attributes.to_h.except("id", "type")).to eql billing_address_resource.attributes.to_h.stringify_keys
      end

      it "should fetch the shipping address" do
        expect(subject.shipping_address).to be_a(address_class)
        expect(subject.shipping_address.attributes.to_h.except("id", "type")).to eql shipping_address_resource.attributes.to_h.stringify_keys
      end

      it "should fetch the shipping method" do
        expect(subject.shipping_method).to be_a(shipping_method_class)
        expect(subject.shipping_method.attributes.to_h.except("id", "type")).to eql shipping_method_resource.attributes.to_h.stringify_keys
      end

    end
  end
end
