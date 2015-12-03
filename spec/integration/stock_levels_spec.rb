require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::StockLevel do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  # The quantity of items to create - changes in different contexts
  let(:quantity) { 0 }
  # The product list - build 'quantity' of them
  let(:resource_list) { build(:stock_level_list, quantity: quantity, base_path: URI.parse(api_root).path) }
  # As a number of specs are testing class methods, subject changes in different contexts
  # so the subject class is defined here for convenience
  let(:subject_class) { FlexCommerce::StockLevel }

  # As the same examples are used in several different contexts
  # to save repeating ourselves, a shared example is defined here
  # which tests for anything common to a collection of stock levels
  shared_examples_for("a collection of stock_levels") do
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
  context "using a collection of stock levels" do
    # Convenient access to the expected total pages of data
    let(:total_pages) { (quantity / page_size.to_f).ceil.to_i }
    # The current page - changes in different contexts
    let(:current_page) { nil }
    # Easy access to the collection URL
    let(:collection_url) { "#{api_root}/stock_levels" }
    let(:stubbed_url) { "#{collection_url}.json_api" }
    # Calculates the expected list quantity
    let(:expected_list_quantity) { quantity }
    # The subject for all examples
    subject { subject_class.where(skus: "1,2,3").all }
    before :each do
      stub_request(:get, stubbed_url).with(headers: { "Accept" => "application/vnd.api+json" }, query: { skus: "1,2,3"}).to_return body: resource_list.to_json, status: response_status, headers: default_headers
    end
    context "with a small data set" do
      let(:quantity) { 10 }
      let(:current_page) { nil }
      context "finding multiple resources" do
        it_should_behave_like "a collection of stock_levels"
      end
    end

    it_should_behave_like "a collection of resources with an error response"
  end
end
