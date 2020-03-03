require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::Taxonomy do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"

  describe "Fetching a taxonomy" do
    context "with Authorisation" do
      it "should return the taxonomy" do
        # Arrange
        stub_request(:get, "#{api_root}/taxonomies/1.json_api")
          .with(headers: {"Accept" => "application/vnd.api+json"})
          .to_return(body: build(:taxonomy_from_fixture).to_json, status: response_status, headers: default_headers)
        # Act
        record = described_class.find(1)
        # Assert
        aggregate_failures do
          expect(record).to be_present
          expect(record).to be_a(described_class)
        end
      end
    end

    context "without Authorisation" do
      it "should raise an AccessDenied exception" do
        # Arrange
        stub_request(:get, "#{api_root}/taxonomies/1.json_api")
          .with(headers: {"Accept" => "application/vnd.api+json"})
          .to_return(body: "", status: 403, headers: nil)

        # Act & Assert
        expect { described_class.find(1) }.to raise_exception(::FlexCommerceApi::Error::AccessDenied)
      end
    end
  end

  describe "Deleting a taxonomy" do
    context "with Authorisation" do
      it "should destroy the record" do
        # Arrange
        resource = build(:taxonomy, id: 1)
        stub_request(:delete, "#{api_root}/taxonomies/1.json_api")
          .with(headers: {"Accept" => "application/vnd.api+json"})
          .to_return(status: 204, headers: default_headers)

        # Assert
        expect(resource.destroy).to eq(true)
      end
    end

    context "without Authorisation" do
      it "should raise an AccessDenied exception" do
        # Arrange
        resource = build(:taxonomy, id: 1)
        stub_request(:delete, "#{api_root}/taxonomies/1.json_api")
          .with(headers: {"Accept" => "application/vnd.api+json"})
          .to_return(body: "", status: 403, headers: nil)
        # Act & Assert
        expect { resource.destroy }.to raise_exception(::FlexCommerceApi::Error::AccessDenied)
      end
    end
  end
end
