require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::PaymentGateway do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  let(:subject_class) { ::FlexCommerce::PaymentGateway }
  let(:payment_gateway_setup_class) { ::FlexCommerce::PaymentGatewaySetup }
  let(:singular_resource) { build(:payment_gateway) }
  context "with fixture files from flex" do
    let(:resource_list) { build(:payment_gateway_list_from_fixture) }
    let(:quantity) { resource_list.data.count }
    let(:total_pages) { 1 }
    let(:expected_list_quantity) { 2 }
    let(:current_page) { nil }
    before :each do
      stub_request(:get, "#{api_root}/payment_gateways.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: resource_list.to_h.to_json, status: response_status, headers: default_headers
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
    context "setup relationship" do
      let(:setup_relationship_data) { resource_list.data.first.relationships.setup.data }
      let(:setup_data) { resource_list.included.detect {|r| r.id == setup_relationship_data.id && r.type == setup_relationship_data.type} }
      it "should have the correct setup from the fixture" do
        subject.first.setup.tap do |setup|
          expect(setup).to be_a(payment_gateway_setup_class)
          setup_data.attributes.to_h.except(:meta_attributes).each_pair do |attr, value|
            expect(setup.send(attr)).to eql value
          end
          setup_data.attributes.meta_attributes.each_pair do |attr, value|
            expect(setup.meta_attributes[attr]).to eql value
          end
        end
      end
    end
  end

end
