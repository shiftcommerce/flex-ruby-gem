require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::BundleGroup do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::BundleGroup }
  let(:product_class) { ::FlexCommerce::Product }

  context "with fixture files from flex" do
    context "working with a single bundle group" do
      let(:singular_resource) { build(:bundle_group_from_fixture) }
      before :each do
        stub_request(:get, "#{api_root}/bundles/1/bundle_groups/1.json_api").with(headers: {"Accept" => "application/vnd.api+json"}).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
      end
      subject { subject_class.where(bundle_id: 1).find(1).first }
      it_should_behave_like "a singular resource with an error response"
      it "should return the correct top level object" do
        expect(subject).to be_a(subject_class)
        expect(subject.title).to eql singular_resource.data.attributes.title
        expect(subject.reference).to eql singular_resource.data.attributes.reference
      end
    end
    context "working with multiple bundle groups" do
      let(:resource_list) { build(:bundle_groups_from_fixture) }
      let(:quantity) { 11 }
      let(:total_pages) { resource_list.meta.page_count }
      let(:current_page) { nil }
      let(:expected_list_quantity) { 10 }
      subject { subject_class.where(bundle_id: 1).all }
      before :each do
        stub_request(:get, "#{api_root}/bundles/1/bundle_groups.json_api").with(headers: {"Accept" => "application/vnd.api+json"}).to_return body: resource_list.to_h.to_json, status: response_status, headers: default_headers
      end
      it_should_behave_like "a collection of anything"
      it_should_behave_like "a collection of resources with an error response"
    end
  end
end
