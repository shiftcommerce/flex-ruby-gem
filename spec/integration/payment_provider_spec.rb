require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::PaymentProvider do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::PaymentProvider }
  let(:singular_resource) { build(:payment_provider) }
  context "with fixture files from flex" do
    let(:resource_list) { build(:payment_provider_list_from_fixture) }
    let(:quantity) { resource_list.data.count }
    let(:total_pages) { 1 }
    let(:expected_list_quantity) { 2 }
    let(:current_page) { nil }
    before :each do
      stub_request(:get, "#{api_root}/payment_providers.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: resource_list.to_h.to_json, status: response_status, headers: default_headers
    end
    subject { subject_class.all }
    it_should_behave_like "a collection of anything"
    it "should have the correct attributes from the fixture" do
      subject.each_with_index do |gateway, idx|
        resource_list.data[idx].tap do |pr|
          expect(gateway.id).to eql pr.id
          pr.attributes.to_h.except(:meta_attributes).each_pair do |attr, value|
            expect(gateway.send(attr)).to eql value
          end
          pr.attributes.meta_attributes.each_pair do |attr, value|
            expect(gateway.meta_attributes[attr]).to eql value
          end
        end
      end
    end
  end

end
