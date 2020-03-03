require "e2e_spec_helper"
RSpec.describe "Markdown Prices API end to end spec", vcr: true do
  # As the "before context" blocks cannot access let vars, the "context store" simply defines a method called "context_store"
  # that stores whatever you want - it is an "OpenStruct" so you can just write anything to it and read it back at any time
  # This is cleared at the start of the context, but the idea is so that you can share stuff between examples.
  # This obviously means that the examples are tied together - in terms of the read, update and delete methods all rely
  # on having created an object in the first place.
  # This also means that this test suite must be run in the order defined, not random.
  include_context "context store"

  # We define the model in advance, mainly allowing the code in the examples to be fairly generic and can be copied / pasted
  # into other tests without changing the model all over the place.
  let(:model) { FlexCommerce::MarkdownPrice }

  # A few convenience lets just to avoid writing context_store.uuid for example
  let(:uuid) { context_store.uuid }
  let(:created_resource) { context_store.created_resource }

  # As setting up for testing can be very expensive, we do it only at the start of then context
  # it is then our responsibility to tidy up at the end of the context.
  before(:context) do
    context_store.uuid = uuid = SecureRandom.uuid
    context_store.foreign_resources = OpenStruct.new
    context_store.foreign_resources.product = FlexCommerce::Product.create! title: "Title for product 1 for variant 1 for markdown price #{context_store.uuid}",
                                                                            reference: "reference for product 1 for variant 1 for markdown price #{context_store.uuid}",
                                                                            content_type: "markdown"
    context_store.foreign_resources.variant = FlexCommerce::Variant.create title: "Title for Test Variant 1 for markdown price #{uuid}",
                                                                           description: "Description for Test Variant 1 for markdown price #{uuid}",
                                                                           reference: "reference_for_test_variant_1_for_markdown_price_#{uuid}",
                                                                           price: 5.50,
                                                                           price_includes_taxes: false,
                                                                           sku: "sku_for_test_variant_1_for_markdown_price#{uuid}",
                                                                           product_id: context_store.foreign_resources.product.id
  end
  # Clean up time - delete stuff in the reverse order to give us more chance of success
  after(:context) do
    context_store.created_resource.destroy unless context_store.created_resource.nil? || !context_store.created_resource.persisted?
    context_store.foreign_resources.to_h.values.reverse_each do |resource|
      resource.destroy if resource.persisted?
    end
  end

  context "#create" do
    it "should persist when valid attributes are used" do
      context_store.created_resource = subject = model.create! price: 99.0,
                                                               start_at: 1.day.since,
                                                               end_at: 11.days.since,
                                                               variant_id: context_store.foreign_resources.variant.id
    end
  end
end
