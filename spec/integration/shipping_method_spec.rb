require "spec_helper"
require "flex_commerce_api"

RSpec.describe FlexCommerce::ShippingMethod do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::ShippingMethod }
  context "with data from factories" do
    context "working with multiple shipping methods" do
      let(:resource_list) { build(:shipping_method_list, quantity: 50) }
      let(:quantity) { 50 }
      let(:total_pages) { 2 }
      let(:current_page) { nil }
      let(:expected_list_quantity) { 25 }
      subject { subject_class.all }
      before :each do
        stub_request(:get, "#{api_root}/shipping_methods.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: resource_list.to_h.to_json, status: response_status, headers: default_headers
      end
      it_should_behave_like "a collection of anything"
      it_should_behave_like "a collection of resources with an error response"
    end
  end
end
