require "e2e_spec_helper"
RSpec.describe "Products API end to end spec", vcr: true do
  # As the "before context" blocks cannot access let vars, the "context store" simply defines a method called "context_store"
  # that stores whatever you want - it is an "OpenStruct" so you can just write anything to it and read it back at any time
  # This is cleared at the start of the context, but the idea is so that you can share stuff between examples.
  # This obviously means that the examples are tied together - in terms of the read, update and delete methods all rely
  # on having created an object in the first place.
  # This also means that this test suite must be run in the order defined, not random.
  include_context "context store"

  def to_clean
    context_store.to_clean
  end

  def asset_file_fixture_file
    # Create an asset file for use by the test
    File.expand_path("../support_e2e/fixtures/asset_file.png", File.dirname(__FILE__))
  end

  # As setting up for testing can be very expensive, we do it only at the start of then context
  # it is then our responsibility to tidy up at the end of the context.
  before(:context) do
    context_store.to_clean = OpenStruct.new
    context_store.foreign_resources.asset_folder = FlexCommerce::AssetFolder.create! name: "asset folder for Test Variant #{context_store.uuid}",
                                                                                     reference: "reference_for_asset_folder_1_for_variant_#{context_store.uuid}"
  end
  # Clean up time - delete stuff in the reverse order to give us more chance of success
  after(:context) do
    to_clean.values.reverse.each do |resource|
      if resource.is_a?(Array)
        resource.each { |r| r.destroy if r.persisted? }
      else
        resource.destroy if resource.persisted?
      end
    end
  end
  let(:uuid) { SecureRandom.uuid }

  context "#create" do
    it "should persist when valid attributes are used" do
      subject = keep_tidy do
        FlexCommerce::Product.create! title: "Title for product  #{uuid}",
                                      reference: "reference for product #{uuid}",
                                      content_type: "markdown"
      end
      expect(subject.errors).to be_empty
      expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
      expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/product")
    end

    it "should persist when valid attributes with nested variants are used" do
      created_resource = keep_tidy do
        FlexCommerce::Product.create! title: "Title for product #{uuid}",
                                      reference: "reference for for product #{uuid}",
                                      content_type: "markdown",
                                      variants_resources: [
                                        FlexCommerce::Variant.new(title: "Title for variant for product #{uuid}",
                                                                  description: "Description for variant for product #{uuid}",
                                                                  reference: "reference_for_variant_for_product_#{uuid}",
                                                                  sku: "sku_for_variant_for_product_#{uuid}",
                                                                  price: 5.50,
                                                                  price_includes_taxes: true)
                                      ]

      end
      aggregate_failures "validating created resource and fetching back" do
        subject = FlexCommerce::Product.find(created_resource.id)
        expect(created_resource.errors).to be_empty
        expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
        expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/product")
        expect(subject.variants).to contain_exactly an_object_having_attributes title: "Title for variant for product #{uuid}"
      end
    end

    it "should persist when valid attributes with nested bundles are used" do
      created_resource = keep_tidy do
        FlexCommerce::Product.create! title: "Title for product #{uuid}",
                                      reference: "reference for for product #{uuid}",
                                      content_type: "markdown",
                                      bundles_resources: [
                                        FlexCommerce::Bundle.new name: "Name for bundle for product #{uuid}",
                                                                 reference: "reference_for_bundle_for_product_#{uuid}",
                                                                 slug: "slug_for_bundle_for_product_#{uuid}",
                                                                 description: "Description for bundle for product #{uuid}"
                                      ]
      end
      aggregate_failures "validating created resource and fetching back" do
        subject = FlexCommerce::Product.find(created_resource.id)
        expect(created_resource.errors).to be_empty
        expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
        expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/product")
        expect(subject.bundles).to contain_exactly an_object_having_attributes name: "Name for bundle for product #{uuid}"
      end
    end

    it "should persist when valid attributes with nested asset files are used" do
      created_resource = keep_tidy do
        FlexCommerce::Product.create! title: "Title for product #{uuid}",
                                      reference: "reference for for product #{uuid}",
                                      content_type: "markdown",
                                      asset_files_resources: [
                                        FlexCommerce::AssetFile.new name: "name for asset file for product #{uuid}",
                                                                    reference: "reference_for_asset_file_for_product_#{uuid}",
                                                                    asset_file: "data:image/png;base64,#{Base64.encode64(File.read(asset_file_fixture_file))}",
                                                                    asset_folder_id: context_store.foreign_resources.asset_folder.id)
        ]
      end
      aggregate_failures "validating created resource and fetching back" do
        subject = FlexCommerce::Product.find(created_resource.id)
        expect(created_resource.errors).to be_empty
        expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
        expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/product")
        expect(subject.asset_files).to contain_exactly an_object_having_attributes name: "Name for asset file for product #{uuid}"
      end
    end

    it "should persist when valid attributes with nested template definition are used" do
      created_resource = keep_tidy do
        FlexCommerce::Product.create! title: "Title for product #{uuid}",
                                      reference: "reference for for product #{uuid}",
                                      content_type: "markdown",
                                      template_definition_resource: FlexCommerce::TemplateDefinition.new(reference: "reference_for_template_definition_for_product_#{uuid}",
                                                                                                         label: "Label for template definition for product #{uuid}",
                                                                                                         data_type: "text")
      end
      aggregate_failures "validating created resource and fetching back" do
        subject = FlexCommerce::Product.find(created_resource.id)
        expect(created_resource.errors).to be_empty
        expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
        expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/product")
        expect(subject.template_definition).to have_attributes reference: "reference_for_template_definition_for_product_#{uuid}"
      end
    end

  end

  context "#read" do
    context "collection" do

    end
    context "member" do

    end
  end

  context "#update" do

  end

  context "#delete" do

  end

end