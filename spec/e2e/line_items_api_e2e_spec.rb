require "e2e_spec_helper"
RSpec.describe "Line items API end to end spec", vcr: true do
  # As the "before context" blocks cannot access let vars, the "context store" simply defines a method called "context_store"
  # that stores whatever you want - it is an "OpenStruct" so you can just write anything to it and read it back at any time
  # This is cleared at the start of the context, but the idea is so that you can share stuff between examples.
  # This obviously means that the examples are tied together - in terms of the read, update and delete methods all rely
  # on having created an object in the first place.
  # This also means that this test suite must be run in the order defined, not random.
  include_context "context store"

  # We define the model in advance, mainly allowing the code in the examples to be fairly generic and can be copied / pasted
  # into other tests without changing the model all over the place.
  let(:model) { FlexCommerce::LineItem }

  before(:context) do
    context_store.uuid = uuid = SecureRandom.uuid
    context_store.foreign_resources = OpenStruct.new
    context_store.foreign_resources.product = FlexCommerce::Product.create! title: "Title for product 1 for variant #{uuid}",
                                                                           reference: "reference for product 1 for variant #{uuid}",
                                                                           content_type: "markdown"
    context_store.foreign_resources.variant = FlexCommerce::Variant.create title: "Title for Test Variant #{uuid}",
                                                            description: "Description for Test Variant #{uuid}",
                                                            reference: "reference_for_test_variant_#{uuid}",
                                                            price: 5.50,
                                                            price_includes_taxes: false,
                                                            sku: "sku_for_test_variant_#{uuid}",
                                                            product_id: context_store.foreign_resources.product.id,
                                                            stock_level: 1
    context_store.created_cart = FlexCommerce::Cart.create!
  end

  context "#create" do
    it "should persist when valid attributes are used" do
      expect {
        FlexCommerce::LineItem.create! \
          item_id: context_store.foreign_resources.variant.id,
          item_type: "Variant",
          unit_quantity: 1,
          container_id: context_store.created_cart.id
          # path: { cart_id: context_store.created_cart.id }
      }.not_to raise_error
    end
  end

  context "#update" do
    it "should persist when valid attributes are used" do
      FlexCommerce::LineItem.create! item_id: context_store.foreign_resources.variant.id, item_type: "Variant", unit_quantity: 1, container_id: context_store.created_cart.id
      context_store.created_cart = FlexCommerce::Cart.find(context_store.created_cart.id) # Reload it
      line_item = context_store.created_cart.line_items.first
      line_item.update(unit_quantity: 5)
      expect(line_item.reload.unit_quantity).to eq(5)
    end
  end
end
