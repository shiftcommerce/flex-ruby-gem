require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe "Shopping Cart" do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::Cart }
  let(:variant_class) { ::FlexCommerce::Variant }
  let(:line_item_class) { ::FlexCommerce::LineItem }
  let(:discount_summary_class) { ::FlexCommerce::DiscountSummary }

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
      end
    end
  end
end
