require "e2e_spec_helper"
RSpec.describe "Variants API end to end spec", vcr: true do
  include_context "context store"
  let(:model) { FlexCommerce::Variant }
  let(:uuid) { context_store.uuid }
  let(:created_resource) { context_store.created_resource }
  let(:created_product) { context_store.foreign_resources[:product] }
  before(:context) do
    context_store.uuid = SecureRandom.uuid
    context_store.foreign_resources = OpenStruct.new
    context_store.foreign_resources[:product] = FlexCommerce::Product.create! title: "Title for product 1 for variant #{context_store.uuid}",
                                                                              reference: "reference for product 1 for variant #{context_store.uuid}",
                                                                              content_type: "markdown"
  end
  after(:context) do
    context_store.created_resource.destroy unless context_store.created_resource.nil? || !context_store.created_resource.persisted?
    context_store.foreign_resources.values.reverse.each do |resource|
      resource.destroy if resource.persisted?
    end
  end

  context "#create" do
    it "should persist when valid attributes are used" do
      context_store.created_resource = subject = model.create title: "Title for Test Variant #{uuid}",
                                                              description: "Description for Test Variant #{uuid}",
                                                              reference: "reference_for_test_variant_#{uuid}",
                                                              price: 5.50,
                                                              price_includes_taxes: false,
                                                              sku: "sku_for_test_variant_#{uuid}",
                                                              product_id: created_product.id
      expect(subject.errors).to be_empty
      expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
      expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/variant")
    end
  end
  context "#read" do
    context "collection" do

    end
    context "member" do
      it "should have the correct default relationships included" do
        subject = model.find(context_store.created_resource.id)
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
          subject = model.includes("product").find(created_resource.id).first
          expect(subject.product).to have_attributes created_product.attributes.slice(:id, :title, :reference, :content_type)
          expect(http_request_tracker.length).to eql 1
        end
        it "should be loadable using links" do
          subject = model.includes("").find(created_resource.id).first
          expect(subject.product).to have_attributes created_product.attributes.slice(:id, :title, :reference, :content_type)
          expect(http_request_tracker.length).to eql 2
        end
      end
      context "asset_files relationship" do
        before(:context) do
          # Create an asset file for use by the test
          asset_file_fixture_file = File.expand_path("../support_e2e/fixtures/asset_file.png", File.dirname(__FILE__))
          uuid = context_store.uuid
          context_store.foreign_resources.asset_folder = FlexCommerce::AssetFolder.create! name: "asset folder for Test Variant #{uuid}",
                                                                                     reference: "reference_for_asset_folder_1_for_variant_#{uuid}"
          context_store.foreign_resources.asset_file = FlexCommerce::AssetFile.create! name: "name for Asset file 1 for Test Variant #{uuid}",
                                                                                       reference: "reference_for_asset_file_1_for_variant_#{uuid}",
                                                                                       asset_file: "data:image/png;base64,#{Base64.encode64(File.read(asset_file_fixture_file))}",
                                                                                       asset_folder_id: context_store.foreign_resources.asset_folder.id
          context_store.foreign_resources.product.update_attributes asset_files_attributes: [ name: "name for Asset file 1 for Test Variant #{uuid}",
                                                                                      reference: "reference_for_asset_file_1_for_variant_#{uuid}",
                                                                                      asset_file: "data:image/png;base64,#{Base64.encode64(File.read(asset_file_fixture_file))}",
                                                                                      asset_folder_id: context_store.foreign_resources.asset_folder.id ]
        end
        it "should exist" do
          subject = model.find(created_resource.id)
          expect(subject.relationships.asset_files).to be_present
        end
        it "should be loadable using compound documents" do
          subject = model.includes("asset_files").find(created_resource.id).first
          expect(subject.asset_files).to contain_exactly an_object_having_attributes created_product.attributes.slice(:id, :title, :reference, :content_type)
          expect(http_request_tracker.length).to eql 1
        end
        it "should be loadable using links" do
          subject = model.includes("").find(created_resource.id).first
          expect(subject.asset_files).to contain_exactly an_object_having_attributes created_product.attributes.slice(:id, :title, :reference, :content_type)
          expect(http_request_tracker.length).to eql 2
        end

      end
      context "markdown prices relationship"
    end
  end

end