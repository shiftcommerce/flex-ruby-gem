require "e2e_spec_helper"
RSpec.describe "Variants API end to end spec", vcr: true do
  # As the "before context" blocks cannot access let vars, the "context store" simply defines a method called "context_store"
  # that stores whatever you want - it is an "OpenStruct" so you can just write anything to it and read it back at any time
  # This is cleared at the start of the context, but the idea is so that you can share stuff between examples.
  # This is useful where you have some expensive or complex setups that dont need to be done for each example, but instead the setup is done
  # for the context.
  # In this file, we use the context store as a global store, mainly for tracking foreign resources to ensure they get setup and deleted correctly
  # it can also be used by nested contexts as long as they tidy up after themselves.
  include_context "context store"
  include_context "housekeeping"

  # We define the model in advance, mainly allowing the code in the examples to be fairly generic and can be copied / pasted
  # into other tests without changing the model all over the place.
  let(:model) { FlexCommerce::Variant }

  # Some global stuff which save having thi clutter inside the tests when we dont care too much about
  # how they are done, we just want them.

  let(:asset_file_fixture_file) do
    # Create an asset file for use by the test
    File.expand_path("../support_e2e/fixtures/asset_file.png", File.dirname(__FILE__))
  end

  let(:global_asset_folder) do
    uuid = SecureRandom.uuid
    to_clean.global_asset_folder ||= FlexCommerce::AssetFolder.create!(name: "asset folder for Test Variant #{uuid}",
                                                                       reference: "reference_for_asset_folder_1_for_variant_#{uuid}").freeze
  end

  let(:global_product) do
    uuid = SecureRandom.uuid
    to_clean.global_product ||= FlexCommerce::Product.create!(title: "Title for product 1 for variant #{uuid}",
                                                              reference: "reference for product 1 for variant #{uuid}",
                                                              content_type: "markdown").freeze
  end

  let(:global_asset_file) do
    uuid = SecureRandom.uuid
    to_clean.global_asset_file ||= FlexCommerce::AssetFile.create! name: "name for Asset file 1 for Test Variant #{uuid}",
                                                                   reference: "reference_for_asset_file_1_for_variant_#{uuid}",
                                                                   asset_file: "data:image/png;base64,#{Base64.encode64(File.read(asset_file_fixture_file))}",
                                                                   asset_folder_id: global_asset_folder.id
  end

  # |------------------------------------------------------------------------|
  # |                    Creating Variants                                   |
  # |                                                                        |
  # |------------------------------------------------------------------------|
  context "#create" do
    # All create examples will use the same subject but "attributes_for_examples" will vary
    # This is done to allow the after each block to keep things tidy automatically
    let(:uuid) { SecureRandom.uuid }
    let(:product) { global_product }
    subject! { model.create attributes_for_examples }
    after(:each) { subject.destroy if subject.persisted? }
    context "with invalid attributes" do
      let(:attributes_for_examples) do
        {
          sku: ""
        }
      end
      it "should not persist and should have errors" do
        expect(subject.persisted?).to be_falsey
        expect(subject.errors).not_to be_empty
      end
    end

    context "valid basic attributes" do
      let(:attributes_for_examples) do
        {
          title: "Title for Test Variant #{uuid}",
          description: "Description for Test Variant #{uuid}",
          reference: "reference_for_test_variant_#{uuid}",
          price: 5.50,
          price_includes_taxes: false,
          sku: "sku_for_test_variant_#{uuid}",
          product_id: product.id
        }
      end

      it "should persist" do
        expect(subject.errors).to be_empty
        expect(http_request_tracker.last[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.last[:response]).to be_valid_json_for_schema("shift/v1/documents/member/variant.json")
      end
    end

    context "valid attributes with valid markdown prices to be created" do
      let(:attributes_for_examples) do
        {
          title: "Title for Test Variant #{uuid} temp 1",
          description: "Description for Test Variant #{uuid}",
          reference: "reference_for_test_variant_#{uuid}_temp_1",
          price: 5.50,
          price_includes_taxes: false,
          sku: "sku_for_test_variant_#{uuid}_temp_1",
          product_id: product.id,

          markdown_prices_resources: [FlexCommerce::MarkdownPrice.new(price: 1.10, start_at: 2.days.ago, end_at: 10.days.since)]
        }
      end

      it "should create the resource with a markdown price" do
        resource = model.includes("markdown_prices").find(subject.id).first
        expect(resource.markdown_prices).to include(an_object_having_attributes(price: 1.10))
      end
    end

    context "valid attributes with valid asset files to be created" do
      # We use our own product in these tests as the asset files are actually stored on the product
      # and we dont want to pollute our global product as it may affect other tests
      let(:product) do
        keep_tidy do
          FlexCommerce::Product.create!(title: "Title for product 1 for variant #{uuid}",
                                        reference: "reference for product 1 for variant #{uuid}",
                                        content_type: "markdown").freeze
        end
      end

      let(:asset_file) do
        keep_tidy do
          FlexCommerce::AssetFile.new(name: "name for Asset file 1 for Test Variant #{uuid} temp",
                                      reference: "reference_for_asset_file_1_for_variant_#{uuid} temp",
                                      asset_file: "data:image/png;base64,#{Base64.encode64(File.read(asset_file_fixture_file))}",
                                      asset_folder_id: global_asset_folder.id)
        end
      end
      let(:attributes_for_examples) do
        {
          title: "Title for Test Variant #{uuid} temp 1",
          description: "Description for Test Variant #{uuid}",
          reference: "reference_for_test_variant_#{uuid}_temp_1",
          price: 5.50,
          price_includes_taxes: false,
          sku: "sku_for_test_variant_#{uuid}_temp_1",
          product_id: product.id,

          asset_files_resources: [asset_file]
        }
      end

      it "should create the resource with an asset file" do
        aggregate_failures "validating resource has the asset file added" do
          resource = model.includes("asset_files").find(subject.id).first
          expect(resource.asset_files).to include(an_object_having_attributes(reference: asset_file.reference))
          keep_tidy { resource.asset_files.first } if resource.asset_files.first.present?
        end
      end
    end
  end

  # |------------------------------------------------------------------------|
  # |                    Reading Variants                                    |
  # |                                                                        |
  # |------------------------------------------------------------------------|
  context "#read collection" do
    let(:uuid) { SecureRandom.uuid }
  end
  context "#read member" do
    # Here we setup for all tests - we create the resource, then the test will read it
    let(:uuid) { SecureRandom.uuid }
    let!(:product) { global_product }
    let!(:created_resource) do
      keep_tidy do
        FlexCommerce::Variant.create(title: "Title for Test Variant #{uuid}",
                                     description: "Description for Test Variant #{uuid}",
                                     reference: "reference_for_test_variant_#{uuid}",
                                     price: 5.50,
                                     price_includes_taxes: false,
                                     sku: "sku_for_test_variant_#{uuid}",
                                     product_id: product.id).freeze
      end
    end

    context "with caching", caching: true do
      let(:uuid) { SecureRandom.uuid }
      let!(:created_resource) do
        keep_tidy do
          FlexCommerce::Variant.create(title: "Title for Test Variant #{uuid}",
                                       description: "Description for Test Variant #{uuid}",
                                       reference: "reference_for_test_variant_#{uuid}",
                                       price: 5.50,
                                       price_includes_taxes: false,
                                       sku: "sku_for_test_variant_#{uuid}",
                                       product_id: product.id).freeze
        end
      end
      it "should indicate the first request after creation is not cached and the second request is" do
        http_request_tracker.clear
        model.find(created_resource.id)
        model.find(created_resource.id)
        # @TODO Work out what these headers should contain when going via fastly
        expect(http_request_tracker.first[:response].headers.keys).to include "Surrogate-Key"
        expect(http_request_tracker[1][:response].headers.keys).to include "Surrogate-Key"
      end
    end

    it "should have the correct default relationships included" do
      subject = model.find(created_resource.id)
      http_request_tracker.clear
      subject.product
      subject.asset_files
      subject.markdown_prices
      expect(http_request_tracker.length).to eql 0
    end

    context "product relationship" do
      it "should exist" do
        subject = model.find(created_resource.id)
        expect(subject.relationships.product).to be_present
      end

      it "should be loadable using compound documents" do
        http_request_tracker.clear
        subject = model.includes("product").find(created_resource.id).first
        expect(subject.product).to have_attributes product.attributes.slice(:id, :title, :reference, :content_type)
        expect(http_request_tracker.length).to eql 1
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/variant.json")
      end

      it "should be loadable using links" do
        http_request_tracker.clear
        subject = model.includes("").find(created_resource.id).first
        expect(subject.product).to have_attributes product.attributes.slice(:id, :title, :reference, :content_type)
        expect(http_request_tracker.length).to eql 2
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/variant.json")
      end
    end

    context "asset_files relationship" do
      # Use our own product for this context as modifying the variants asset files modifys the product
      let(:product) do
        keep_tidy do
          FlexCommerce::Product.create!(title: "Title for product 1 for variant #{uuid}",
                                        reference: "reference for product 1 for variant #{uuid}",
                                        content_type: "markdown").freeze
        end
      end

      let(:asset_file) { global_asset_file }
      before(:each) do
        product.add_asset_files([asset_file])
      end

      it "should exist" do
        subject = model.find(created_resource.id)
        expect(subject.relationships.asset_files).to be_present
      end

      it "should be loadable using compound documents" do
        http_request_tracker.clear
        subject = model.includes("asset_files").find(created_resource.id).first
        expect(subject.asset_files).to contain_exactly an_object_having_attributes asset_file.attributes.slice(:id, :title, :reference, :content_type)
        expect(http_request_tracker.length).to eql 1
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/variant.json")
      end

      it "should be loadable using links" do
        http_request_tracker.clear
        subject = model.includes("").find(created_resource.id).first
        expect(subject.asset_files).to contain_exactly an_object_having_attributes asset_file.attributes.slice(:id, :title, :reference, :content_type)
        expect(http_request_tracker.length).to eql 2
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/variant.json")
      end
    end

    context "markdown prices relationship" do
      let!(:markdown_price) do
        # No need to keep this tidy, it will be deleted with the variant
        ::FlexCommerce::MarkdownPrice.create!(price: 99.0,
                                              start_at: 1.day.since,
                                              end_at: 11.days.since,
                                              variant_id: created_resource.id).freeze
      end

      it "should exist" do
        subject = model.find(created_resource.id)
        expect(subject.relationships.markdown_prices).to be_present
      end

      it "should be loadable using compound documents" do
        http_request_tracker.clear
        subject = model.includes("markdown_prices").find(created_resource.id).first
        expect(subject.markdown_prices).to contain_exactly an_object_having_attributes markdown_price.attributes.slice(:id, :price, :start_at, :end_at)
        expect(http_request_tracker.length).to eql 1
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/variant.json")
      end

      it "should be loadable using links" do
        http_request_tracker.clear
        subject = model.includes("").find(created_resource.id).first
        expect(subject.markdown_prices).to contain_exactly an_object_having_attributes markdown_price.attributes.slice(:id, :price, :start_at, :end_at)
        expect(http_request_tracker.length).to eql 2
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("jsonapi/schema.json")
        expect(http_request_tracker.first[:response]).to be_valid_json_for_schema("shift/v1/documents/member/variant.json")
      end
    end
  end

  # |------------------------------------------------------------------------|
  # |                    Updating Variants                                   |
  # |                                                                        |
  # |------------------------------------------------------------------------|

  context "#update" do
    # Setup for all tests here - so we create a resource to be updated.  Each example will then read this from API
    let(:uuid) { SecureRandom.uuid }
    let!(:product) { global_product }
    let!(:created_resource) do
      model.create title: "Title for Test Variant #{uuid}",
                   description: "Description for Test Variant #{uuid}",
                   reference: "reference_for_test_variant_#{uuid}",
                   price: 5.50,
                   price_includes_taxes: false,
                   sku: "sku_for_test_variant_#{uuid}",
                   product_id: product.id
    end

    # A common subject for all examples - as the examples test the updating
    subject { model.includes("").find(created_resource.id).first }
    after(:each) { created_resource.destroy if created_resource.persisted? }

    it "should persist changes to core attributes with valid values" do
      result = subject.update_attributes title: "Title for product 1 for variant #{uuid} changed",
                                         reference: "reference for product 1 for variant #{uuid} changed",
                                         content_type: "html"
      expect(result).to be true
      expect(subject.errors).to be_empty
    end

    it "should not persist changes and have errors when invalid attributes are used" do
      aggregate_failures do
        expect(subject.update_attributes(sku: nil)).to be false
        expect(subject.errors).to be_present
      end
    end

    it "should accept updates containing mirrored attributes" do
      result = subject.update_attributes subject.attributes.except("id", "type")
      expect(result).to be true
      expect(subject.errors).to be_empty
    end

    it "should not make any changes when updated with mirrored attributes" do
      data = Oj.load(http_request_tracker.first[:response].body)
      data["data"] = data["data"].except("relationships", "links", "meta")
      url = "#{model.site}/#{found.links.self}"
      result = model.connection.run(:patch, found.links.self, data.to_json)
      expect(true).to eql false # TODO Test the status code and re fetch to ensure no changes
    end

    context "product relationship" do
      it "should persist additions to the relationship"
      it "should not persist an addition to the relationship if it already exists"
      it "should replace entire relationship"
      it "should remove from the existing relationship"
    end

    context "asset_files relationship" do
      # Use our own product for this context as modifying the variants asset files modifys the product
      let(:product) do
        keep_tidy do
          FlexCommerce::Product.create!(title: "Title for product 1 for variant #{uuid}",
                                        reference: "reference for product 1 for variant #{uuid}",
                                        content_type: "markdown").freeze
        end
      end
      it "should persist additions to the relationship"
      it "should not persist an addition to the relationship if it already exists"
      it "should replace entire relationship"
      it "should remove from the existing relationship"
    end

    context "markdown_prices relationship" do
      it "should be able to add a new markdown price" do
        result = subject.update_attributes(markdown_prices_resources: [FlexCommerce::MarkdownPrice.new(price: 1.10, start_at: 2.days.ago, end_at: 10.days.since)])
        expect(result).to be_truthy
        resource = model.includes("markdown_prices").find(created_resource.id).first
        expect(resource.markdown_prices).to include(an_object_having_attributes(price: 1.10))
      end
      it "should persist additions to the relationship" do
        # This is not possible as the markdown price cannot exist without a variant id
        # but I am leaving it in here to keep the structure in place for now.
      end
      it "should not persist an addition to the relationship if it already exists" do
        to_clean.markdown_price = FlexCommerce::MarkdownPrice.create!(variant_id: subject.id, price: 1.10, start_at: 2.days.ago, end_at: 10.days.since)
        operation = -> { created_resource.add_markdown_prices([to_clean.markdown_price]) }
        expect(operation).to raise_error(FlexCommerceApi::Error::BadRequest)
      end
      it "should replace entire relationship"
      it "should remove from the existing relationship"
    end
  end

  # |------------------------------------------------------------------------|
  # |                    Deleting Variants                                   |
  # |                                                                        |
  # |------------------------------------------------------------------------|
  context "#delete" do
    it "should delete"
  end
end
