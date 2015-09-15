require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::CustomerAccount do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"
  # As a number of specs are testing class methods, subject changes in different contexts
  # so the subject class is defined here for convenience
  let(:subject_class) { FlexCommerce::CustomerAccount }

  # |---------------------------------------------------------|
  # | Examples Start Here                                     |
  # |---------------------------------------------------------|

  #
  # Member Examples
  #
  context "using a single resource" do
    let(:resource_identifier) { build(:json_api_resource, build_resource: :customer_account, base_path: base_path) }
    let(:singular_resource) { build(:json_api_top_singular_resource, data: resource_identifier) }
    before :each do
      stub_request(:get, "#{api_root}/customer_accounts/#{resource_identifier.id}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: response_status, headers: default_headers
    end
    context "finding a single resource" do
      it_should_behave_like "a singular resource"
      context "using the primary key" do
        subject { subject_class.find(resource_identifier.id) }
        it_should_behave_like "a singular resource with an error response"
        it "should return an object with the correct attributes when find is called" do
          expect(subject.attributes.as_json.reject { |k| %w(id type links meta relationships).include?(k) }.with_indifferent_access).to eql(resource_identifier.attributes.as_json.with_indifferent_access)
          expect(subject.type).to eql "customer_accounts"
        end
      end
    end
  end

  context "using fixture data for a single resource" do
    let(:singular_resource) { build(:customer_account_from_fixture) }
    let(:resource_identifier) { singular_resource.data }
    before :each do
      stub_request(:get, "#{api_root}/customer_accounts/#{resource_identifier.id}.json_api").with(headers: { "Accept" => "application/vnd.api+json" }).to_return body: singular_resource.to_h.to_json, status: 200, headers: default_headers
    end
    it_should_behave_like "a singular resource"
    context "with subject set" do
      subject { subject_class.find(resource_identifier.id) }
      it "should return an object with the correct attributes" do
        resource_identifier.attributes.each_pair do |attr, value|
          expect(subject.send(attr)).to eql value
        end
      end
    end
  end
end
