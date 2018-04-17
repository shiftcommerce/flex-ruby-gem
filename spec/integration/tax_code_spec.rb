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
      it "should return the tax_code collection" do
        # Arrange
        stub_request(:get, "#{api_root}/tax_codes.json_api").
          with(headers: { "Accept" => "application/vnd.api+json" }).
          to_return(body: build(:tax_codes_from_fixture).to_json, status: response_status, headers: default_headers)

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
      it "should raise an AccessDenied exception" do
        # Arrange
        stub_request(:get, "#{api_root}/tax_codes.json_api").
          with(headers: { "Accept" => "application/vnd.api+json" }).
          to_return(body: '', status: 403, headers: nil)

        # Act & Assert
        expect { described_class.all }.to raise_exception(::FlexCommerceApi::Error::AccessDenied)
      end
    end
  end

  context "fetching a tax code" do
    context "with Authorisation" do
      it "should return the tax_code" do
        # Arrange
        stub_request(:get, "#{api_root}/tax_codes/1.json_api").
          with(headers: { "Accept" => "application/vnd.api+json" }).
          to_return(body: build(:tax_code_from_fixture).to_json, status: response_status, headers: default_headers)

        # Act
        record = described_class.find(1)

        # Assert
        expect(record).to be_a(described_class)
      end
    end

    context "without Authorisation" do
      it "should raise an AccessDenied exception" do
        # Arrange
        stub_request(:get, "#{api_root}/tax_codes/1.json_api").
          with(headers: { "Accept" => "application/vnd.api+json" }).
          to_return(body: '', status: 403, headers: nil)

        # Act & Assert
        expect { described_class.find(1) }.to raise_exception(::FlexCommerceApi::Error::AccessDenied)
      end
    end
  end
      
  context "creating a new tax code" do
    context "with valid attributes" do
      it "should create a TaxCode" do
        # Arrange
        tax_code_attributes = attributes_for(:tax_code)
        resource = build(:tax_code, tax_code_attributes)

        stub_request(:post, "#{api_root}/tax_codes.json_api").
          with(headers: { "Accept" => "application/vnd.api+json" }).
          to_return body: resource.to_json, status: 201, headers: default_headers

        # Act
        record = described_class.create(tax_code_attributes)

        # Assert
        aggregate_failures do
          expect(record).to be_a(described_class)
          expect(record.code).to eq(resource.code)
        end
      end
    end

    context "with invalid attributes" do
      it "should create a TaxCode" do
        # Arrange
        tax_code_attributes = attributes_for(:tax_code, code: '')

        stub_request(:post, "#{api_root}/tax_codes.json_api").
          with(headers: { "Accept" => "application/vnd.api+json" }).
          to_return(body: File.read("spec/fixtures/tax_codes/error_response.json"), status: 422, headers: default_headers)

        # Act
        record = described_class.create(tax_code_attributes)

        # Assert
        aggregate_failures do
          expect(record.errors).to be_present
          expect(record.errors.details.keys).to include(:code)
        end
      end
    end

    context "without Authorisation" do
      it "should raise an AccessDenied exception" do
        # Arrange
        tax_code_attributes = attributes_for(:tax_code)

        stub_request(:post, "#{api_root}/tax_codes.json_api").
          with(headers: { "Accept" => "application/vnd.api+json" }).
          to_return(body: '', status: 403, headers: nil)

        # Act & Assert
        expect { described_class.create(tax_code_attributes) }.to raise_exception(::FlexCommerceApi::Error::AccessDenied)
      end
    end
  end

  context "updating a tax code" do
    context "with valid attributes" do
      it "should updates a TaxCode" do
        # Arrange
        new_code_attributes = { code: "test update" }
        tax_code_attributes = attributes_for(:tax_code, id: 1)
        resource = build(:tax_code, tax_code_attributes)

        stub_request(:post, "#{api_root}/tax_codes.json_api").
          with(headers: { "Accept" => "application/vnd.api+json" }).
          to_return body: tax_code_attributes.merge(new_code_attributes).to_json, status: 200, headers: default_headers

        # Act & Assert
        expect(resource.update_attributes(new_code_attributes)).to be_truthy
      end
    end

    context "with invalid attributes" do
      it "should updates a TaxCode" do
        # Arrange
        tax_code_attributes = attributes_for(:tax_code, id: 1)
        resource = build(:tax_code, tax_code_attributes)

        stub_request(:post, "#{api_root}/tax_codes.json_api").
          with(headers: { "Accept" => "application/vnd.api+json" }).
          to_return(body: File.read("spec/fixtures/tax_codes/error_response.json"), status: 422, headers: default_headers)

        # Act
        resource.update_attributes({ code: "" })

        # Assert
        aggregate_failures do
          expect(resource.errors).to be_present
          expect(resource.errors.details.keys).to include(:code)
        end
      end
    end

    context "without Authorisation" do
      it "should raise an AccessDenied exception" do
        # Arrange
        new_code_attributes = { code: "test update" }
        resource = build(:tax_code, id: 1)

        stub_request(:post, "#{api_root}/tax_codes.json_api").
          with(headers: { "Accept" => "application/vnd.api+json" }).
          to_return(body: '', status: 403, headers: nil)

        # Act & Assert
        expect { resource.update_attributes({ code: "test update" }) }.to raise_exception(::FlexCommerceApi::Error::AccessDenied)
      end
    end
  end

  context "deleting a tax code" do
    it "should destroy a tax code" do
      # Arrange
      resource = build(:tax_code, id: 1)

      stub_request(:delete, "#{api_root}/tax_codes/1.json_api").
        with(headers: { "Accept" => "application/vnd.api+json" }).
        to_return(status: 204, headers: default_headers)

      # Assert
      expect(resource.destroy).to eq(true)
    end
  end
end
