require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::CategoryTree do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::CategoryTree }
  let(:category_class) { ::FlexCommerce::Category }

  context "with fixture files from flex" do
    context "working with a single category tree" do
      let(:singular_resource) { build(:category_tree_from_fixture) }
      before :each do
        stub_request(:get, "#{api_root}/category_trees/test-category-tree.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
      end
      subject { subject_class.find("test-category-tree") }
      it_should_behave_like "a singular resource with an error response"
      it "should return the correct top level object" do
        expect(subject).to be_a(subject_class)
        expect(subject.title).to eql singular_resource.data.attributes.title
        expect(subject.reference).to eql singular_resource.data.attributes.reference
      end
      context "using the categories association" do
        before :each do
          stub_request(:get, "#{flex_root}#{singular_resource.data.relationships.categories.links.related}").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: multiple_category_resources.to_h.to_json, status: response_status, headers: default_headers
          stub_request(:get, "#{flex_root}#{singular_resource.data.relationships.categories.links.related}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: multiple_category_resources.to_h.to_json, status: response_status, headers: default_headers
        end
        let(:multiple_category_resources) { build(:categories_from_fixture) }
        it "should return a list of categories" do
          subject.categories.tap do |categories|
            expect(categories.length).to eql multiple_category_resources.data.length
            categories.each_with_index do |category, idx|
              expect(category).to be_a(category_class)
            end
          end
        end
        it "should return a list of categories with the correct attributes" do
          subject.categories.tap do |categories|
            expect(categories.length).to eql multiple_category_resources.data.length
            categories.each_with_index do |category, idx|
              category_resource = multiple_category_resources.data[idx]
              category_resource.attributes.each_pair do |attr, value|
                expect(category.send(attr)).to eql value
              end
            end
          end
        end
      end
    end
    context "working with multiple category trees" do
      let(:resource_list) { build(:category_trees_from_fixture) }
      let(:quantity) { 2 }
      let(:total_pages) { resource_list.meta.page_count }
      let(:current_page) { nil }
      let(:expected_list_quantity) { 2 }
      subject { subject_class.all }
      before :each do
        stub_request(:get, "#{api_root}/category_trees.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: resource_list.to_h.to_json, status: response_status, headers: default_headers
      end
      it_should_behave_like "a collection of anything"
      it_should_behave_like "a collection of resources with an error response"

    end
  end
end
