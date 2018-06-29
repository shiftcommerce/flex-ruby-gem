require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::V2::Order do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context", api_version: "v2"
  # As a number of specs are testing class methods, subject changes in different contexts
  # so the subject class is defined here for convenience
  let(:subject_class) { FlexCommerce::V2::Order }

  #
  # Member Examples
  #
  context "using a single resource" do
    let(:singular_resource) { build(:v2_order_from_fixture) }
    context "fetching a single order" do
      before :each do
        stub_request(:get, "#{api_root}/orders/1.json_api").with(headers: {"Accept" => "application/vnd.api+json"}).to_return body: singular_resource.to_json, status: response_status, headers: default_headers
      end
      subject { subject_class.find(1) }
      it_should_behave_like "a singular resource with an error response"
      it "should return the correct top level object" do
        expect(subject).to be_a(subject_class)
      end
    end
  end
end
