require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::Category do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::Category }
  let(:product_class) { ::FlexCommerce::Product }

  context "with fixture files from flex" do
    context "working with a single category" do
      let(:singular_resource) { build(:category_from_fixture) }
      before :each do
        stub_request(:get, "#{api_root}/category_trees/test-tree/categories/test-category.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
      end
      subject { subject_class.where(category_tree_id: "test-tree").find("test-category").first }
      it_should_behave_like "a singular resource with an error response"
      it "should return the correct top level object" do
        expect(subject).to be_a(subject_class)
        expect(subject.title).to eql singular_resource.data.attributes.title
        expect(subject.reference).to eql singular_resource.data.attributes.reference
      end
      context "using the products association" do
        before :each do
          stub_request(:get, "#{flex_root}#{singular_resource.data.relationships.products.links.related}").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: multiple_product_resources.to_h.to_json, status: response_status, headers: default_headers
        end
        let(:multiple_product_resources) { build(:product_list_from_fixture) }
        it "should return a list of products" do
          subject.products.tap do |products|
            expect(products.length).to eql multiple_product_resources.data.length
            products.each_with_index do |product, idx|
              expect(product).to be_a(product_class)
            end
          end
        end
        it "should return a list of products with the correct attributes" do
          subject.products.tap do |products|
            expect(products.length).to eql multiple_product_resources.data.length
            products.each_with_index do |product, idx|
              product_resource = multiple_product_resources.data[idx]
              product_resource.attributes.each_pair do |attr, value|
                expect(product.send(attr)).to eql value
              end
            end
          end
        end
      end
    end
    context "working with multiple categories" do
      let(:resource_list) { build(:categories_from_fixture) }
      let(:quantity) { 11 }
      let(:total_pages) { resource_list.meta.page_count }
      let(:current_page) { nil }
      let(:expected_list_quantity) { 10 }
      subject { subject_class.where(category_tree_id: "test-tree").all }
      before :each do
        stub_request(:get, "#{api_root}/category_trees/test-tree/categories.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: resource_list.to_h.to_json, status: response_status, headers: default_headers
      end
      it_should_behave_like "a collection of anything"
      it_should_behave_like "a collection of resources with an error response"

    end
  end
end
