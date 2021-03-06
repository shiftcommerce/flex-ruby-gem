require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::StaticPage do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  # The quantity of items to create - changes in different contexts
  let(:quantity) { 0 }
  # The product list - build 'quantity' of them
  let(:resource_list) { build(:static_page_list, quantity: quantity, base_path: URI.parse(api_root).path) }
  # As a number of specs are testing class methods, subject changes in different contexts
  # so the subject class is defined here for convenience
  let(:subject_class) { FlexCommerce::StaticPage }

  # As the same examples are used in several different contexts
  # to save repeating ourselves, a shared example is defined here
  # which tests for anything common to a collection of products
  shared_examples_for("a collection of static pages") do
    it_should_behave_like "a collection of anything"
    it "should return the correct number of instances and the meta data should be correct" do
      subject.each_with_index do |p, idx|
        resource_list.data[idx].tap do |resource_identifier|
          expect(p.id).to eql(resource_identifier.id)
          expect(p.attributes.as_json.reject { |k| %w(id type links meta relationships).include?(k) }).to eql(resource_identifier.attributes.as_json)
        end
      end
    end
  end
  # |---------------------------------------------------------|
  # | Examples Start Here                                     |
  # |---------------------------------------------------------|

  #
  # All collection examples
  #
  context "using a collection of static pages" do
    # Convenient access to the expected total pages of data
    let(:total_pages) { (quantity / page_size.to_f).ceil.to_i }
    # The current page - changes in different contexts
    let(:current_page) { nil }
    # Easy access to the collection URL
    let(:collection_url) { "#{api_root}/static_pages" }
    # Calculates the stubbed_url depending on if current_page is nil or not
    #  If current page is nil, then it is expected that the test will fetch its data from the collection_url rather
    #  than the paginated version.
    let(:stubbed_url) { "#{collection_url}.json_api" }
    # Calculates the expected list quantity
    let(:expected_list_quantity) { quantity == 0 ? 0 : ((quantity - 1) % page_size) + 1 }
    # The subject for all examples - using pagination as this is expected normally
    subject { subject_class.paginate(page: current_page).all }
    before :each do
      if current_page.present?
        stub_request(:get, stubbed_url).with(headers: { "Accept" => "application/vnd.api+json" }, query: { page: { number: current_page } }).to_return body: resource_list.to_json, status: response_status, headers: default_headers
      else
        stub_request(:get, stubbed_url).with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: resource_list.to_json, status: response_status, headers: default_headers
      end
    end
    it_should_behave_like "a collection of resources with various data sets", resource_type: :static_page
    it_should_behave_like "a collection of resources with an error response"
  end

  #
  # Member Examples
  #
  context "using a single resource" do
    let(:resource_identifier) { build(:json_api_resource, build_resource: :static_page, base_path: base_path) }
    let(:singular_resource) { build(:json_api_top_singular_resource, data: resource_identifier) }
    before :each do
      stub_request(:get, "#{api_root}/static_pages/#{resource_identifier.id}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_json, status: response_status, headers: default_headers
    end
    context "finding a single resource" do
      subject { subject_class.find(resource_identifier.id) }
      it_should_behave_like "a singular resource"
      it_should_behave_like "a singular resource with an error response"
      it "should return an object with the correct attributes when find is called" do
        expect(subject.attributes.as_json.reject { |k| %w(id type links meta relationships).include?(k) }).to eql(resource_identifier.attributes.as_json)
      end
    end
  end
end
