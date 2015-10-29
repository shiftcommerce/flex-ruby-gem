require "spec_helper"
require "flex_commerce_api"

RSpec.describe FlexCommerce::Address do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::Address }
  let(:account_class) { ::FlexCommerce::CustomerAccount }
  context "with fixture files from flex" do
    let(:customer_account_document) { build(:customer_account_from_fixture, api_root: api_root) }
    let(:customer_account) { customer_account_document.data }
    context "working with multiple addresses" do
      let(:resource_list) { build(:addresses_from_fixture) }
      let(:quantity) { 50 }
      let(:total_pages) { resource_list.meta.page_count }
      let(:current_page) { nil }
      let(:expected_list_quantity) { 10 }
      subject { subject_class.where(customer_account_id: customer_account.id).all }
      before :each do
        stub_request(:get, "#{api_root}/customer_accounts/#{customer_account.id}.json_api").with(headers: default_request_headers).to_return body: customer_account_document.to_json, status: response_status, headers: default_headers
        stub_request(:get, "#{api_root}/customer_accounts/#{customer_account.id}/addresses.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: resource_list.to_h.to_json, status: response_status, headers: default_headers
      end
      it_should_behave_like "a collection of anything"
      it_should_behave_like "a collection of resources with an error response"


    end

  end

end
