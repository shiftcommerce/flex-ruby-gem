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

  def keep_tidy
    yield.tap do |o|
      to_clean.dumping_ground ||= []
      to_clean.dumping_ground << o
    end
  end

  def asset_file_fixture_file
    # Create an asset file for use by the test
    File.expand_path("../support_e2e/fixtures/asset_file.png", File.dirname(__FILE__))
  end

  # As setting up for testing can be very expensive, we do it only at the start of then context
  # it is then our responsibility to tidy up at the end of the context.
  before(:context) do
    uuid = SecureRandom.uuid
    context_store.to_clean = OpenStruct.new
    context_store.to_clean.asset_folder = FlexCommerce::AssetFolder.create! name: "asset folder for Test Variant #{uuid}",
                                                                            reference: "reference_for_asset_folder_1_for_variant_#{uuid}"
  end
  # Clean up time - delete stuff in the reverse order to give us more chance of success
  after(:context) do
    to_clean.to_h.values.reverse.each do |resource|
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
        subject = FlexCommerce::Product.includes("variants").find(created_resource.id).first
        expect(created_resource.errors).to be_empty
        expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
        expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/product")
        expect(subject.variants).to contain_exactly an_object_having_attributes title: "Title for variant for product #{uuid}"
      end
    end

    it "should persist when valid attributes with nested asset files are used" do
      created_resource = keep_tidy do
        FlexCommerce::Product.create! title: "Title for product #{uuid}",
                                      reference: "reference for for product #{uuid}",
                                      content_type: "markdown",
                                      asset_files_resources: [
                                          FlexCommerce::AssetFile.new(name: "name for asset file for product #{uuid}",
                                                                      reference: "reference_for_asset_file_for_product_#{uuid}",
                                                                      asset_file: "data:image/png;base64,#{Base64.encode64(File.read(asset_file_fixture_file))}",
                                                                      asset_folder_id: context_store.to_clean.asset_folder.id)
                                      ]
      end
      aggregate_failures "validating created resource and fetching back" do
        subject = FlexCommerce::Product.includes("asset_files").find(created_resource.id).first
        expect(created_resource.errors).to be_empty
        expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
        expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/product")
        expect(subject.asset_files).to contain_exactly an_object_having_attributes name: "name for asset file for product #{uuid}"
      end
    end

    it "should persist when valid attributes with nested template definition are used" do
      created_resource = keep_tidy do
        FlexCommerce::Product.create! title: "Title for product #{uuid}",
                                      reference: "reference for for product #{uuid}",
                                      content_type: "markdown",
                                      template_definition_resource: FlexCommerce::TemplateDefinition.new(reference: "reference_for_template_definition_for_product_#{uuid}",
                                                                                                         label: "Label for template definition for product #{uuid}",
                                                                                                         data_type: "Product")
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
      before(:context) do
        context_store.collection = 3.times.map do |i|
          keep_tidy do
            uuid = SecureRandom.uuid
            FlexCommerce::Product.create! title: "Title for product #{uuid}",
                                          description: "Description for product #{uuid}",
                                          reference: "reference for product #{uuid}",
                                          content_type: "markdown",
                                          sellable: true,
                                          available_to_browse: true
          end
        end
      end
      it "Should contain these 3 records in a page" do
        expect(FlexCommerce::Product.page(1).per(100)).to include_in_any_page *context_store.collection.map { |r| an_object_having_attributes(title: r.title) }
      end

      it "Should find one of these when searched for" do
        uuid = context_store.collection.first.reference.split("reference for product ").last
        expect(FlexCommerce::Product.temp_search(filter: {title: {cont: uuid}}.to_json).all).to include an_object_having_attributes(title: context_store.collection.first.title)
      end
    end
    context "member" do
      before(:context) do
        context_store.member = keep_tidy do
          uuid = SecureRandom.uuid
          FlexCommerce::Product.create! title: "Title for product #{uuid}",
                                        description: "Description for product #{uuid}",
                                        reference: "reference for for product #{uuid}",
                                        content_type: "markdown"
        end
      end
      it "should be found" do
        expect(FlexCommerce::Product.find(context_store.member.id)).to have_attributes title: context_store.member.title
        expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
        expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/product")
      end

    end
  end

  context "#update" do

  end

  context "#delete" do

  end

end