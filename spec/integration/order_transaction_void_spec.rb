require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::OrderTransactionVoid do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::OrderTransactionVoid }
  let(:singular_resource) { build(:order_transaction_void_from_fixture) }
  context "with fixture files from flex" do
    before :each do
      stub_request(:post, "#{api_root}/orders/1/transactions/10/order_transaction_voids.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
    end
    subject { subject_class.create(order_id: 1, transaction_id: 10) }
    it "should have the correct attributes from the fixture" do
      expect(subject).to have_attributes(token: instance_of(String), auth_id: instance_of(String))
    end
  end

end
