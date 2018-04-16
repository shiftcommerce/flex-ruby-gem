require "spec_helper"
require "flex_commerce_api"
require "uri"

RSpec.describe FlexCommerce::TaxCode do
  # Global context for all specs - defines things you dont see defined in here
  # such as flex_root_url, api_root, default_headers and page_size
  # see api_globals.rb in spec/support for the source code
  include_context "global context"

  context "fetching all tax codes" do
    context "with Authorisation" do
      before(:each) do
        stub_request(:get, "#{api_root}/tax_codes.json_api").
          with(headers: {"Accept" => "application/vnd.api+json"}).
          to_return(body: build(:tax_codes_from_fixture).to_json, status: response_status, headers: default_headers)
      end

      it "should return the tax_code collection" do
        # Act
        records = described_class.all

        # Assert
        aggregate_failures do
          expect(records.count).to eq(4)
          expect(records.first).to be_a(described_class)
        end
      end
    end

    context "without Authorisation" do
      before(:each) do
        stub_request(:get, "#{api_root}/tax_codes.json_api").
          with(headers: {"Accept" => "application/vnd.api+json"}).
          to_return(body: build(:tax_codes_from_fixture).to_json, status: 401, headers: nil)
      end

      subject { described_class.all }

      it_should_behave_like "a collection of resources with an error response"
    end
  end

  context "fetching a tax code" do
    context "with Authorisation" do
      before(:each) do
        stub_request(:get, "#{api_root}/tax_codes/1.json_api").
          with(headers: {"Accept" => "application/vnd.api+json"}).
          to_return(body: build(:tax_code_from_fixture).to_json, status: response_status, headers: default_headers)
      end

      it "should return the tax_code" do
        # Act
        record = described_class.find(1)

        # Assert
        expect(record).to be_a(described_class)
      end
    end

    context "without Authorisation" do
      before(:each) do
        stub_request(:get, "#{api_root}/tax_codes/1.json_api").
          with(headers: {"Accept" => "application/vnd.api+json"}).
          to_return(body: build(:tax_code_from_fixture).to_json, status: 401, headers: nil)
      end

      subject { described_class.find(1) }

      it_should_behave_like "a singular resource with an error response"
    end
  end
end
