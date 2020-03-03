require "e2e_spec_helper"
RSpec.describe "Orders API end to end spec", vcr: true do
  # As the "before context" blocks cannot access let vars, the "context store" simply defines a method called "context_store"
  # that stores whatever you want - it is an "OpenStruct" so you can just write anything to it and read it back at any time
  # This is cleared at the start of the context, but the idea is so that you can share stuff between examples.
  # This obviously means that the examples are tied together - in terms of the read, update and delete methods all rely
  # on having created an object in the first place.
  # This also means that this test suite must be run in the order defined, not random.
  include_context "context store"

  # We define the model in advance, mainly allowing the code in the examples to be fairly generic and can be copied / pasted
  # into other tests without changing the model all over the place.
  let(:model) { FlexCommerce::Order }

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
    FlexCommerce::LineItem.create! item_id: context_store.foreign_resources.variant.id, item_type: "Variant", unit_quantity: 1, container_id: context_store.created_cart.id
    context_store.created_cart = FlexCommerce::Cart.find(context_store.created_cart.id) # Reload it
    context_store.foreign_resources.address = FlexCommerce::Address.create! first_name: "First",
                                                                            last_name: "Last",
                                                                            address_line_1: "Address Line 1",
                                                                            city: "Leeds",
                                                                            postcode: "LS2 1AA",
                                                                            country: "UK"
    context_store.foreign_resources.shipping_method = FlexCommerce::ShippingMethod.create label: "Shipping Method for #{uuid}",
                                                                                          reference: "reference_for_#{uuid}",
                                                                                          description: "Description for #{uuid}",
                                                                                          total: 1.50,
                                                                                          tax_rate: 0.2
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
      context_store.created_resource = subject = model.create! email: "#{context_store.uuid}@test.com",
                                                               cart_id: context_store.created_cart.id,
                                                               shipping_address_id: context_store.foreign_resources.address.id,
                                                               billing_address_id: context_store.foreign_resources.address.id,
                                                               shipping_method_id: context_store.foreign_resources.shipping_method.id,
                                                               transaction_attributes: {
                                                                 status: "success",
                                                                 transaction_type: "settlement",
                                                                 payment_gateway_reference: "null",
                                                                 amount: 1.80,
                                                                 currency: "GBP"
                                                               }
      tmp = 1
    end
  end
  context "#read" do
    context "collection" do
    end
    context "member" do
    end
  end
end
