require "e2e_spec_helper"
RSpec.describe "Variants API end to end spec", vcr: true do
  include_context "context store"
  let(:model) { FlexCommerce::Variant }
  before(:context) do
    context_store.uuid = SecureRandom.uuid
    context_store.foreign_resources = {}
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
      uid = context_store.uuid
      context_store.created_resource = subject = model.create title: "Title for Test Variant #{uid}",
                             description: "Description for Test Variant #{uid}",
                             reference: "reference_for_test_variant_#{uid}",
                             price: 5.50,
                             price_includes_taxes: false,
                             sku: "sku_for_test_variant_#{uid}",
                             product_id: context_store.foreign_resources[:product].id
      expect(subject.errors).to be_empty
      expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
      expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/variant")
    end
  end

end