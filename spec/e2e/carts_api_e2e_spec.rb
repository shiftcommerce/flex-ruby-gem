require "e2e_spec_helper"
RSpec.describe "Carts API end to end spec" do
  let(:model) { FlexCommerce::Cart }
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:cart) }
    let(:attributes_to_update) { { email: "#{base_attributes[:email]}CHANGED" } }
  end
  context "shipping_methods relationship" do
    #index
  end
  context "shipping_promotions relationship" do
    #index
  end
  context "coupons relationship" do

  end
  context "billing_address relationship" do

  end
  context "shipping_address relationship" do
    shared_examples_for "any shipping address" do
      it "should have a shipping address" do
        expect(subject).to have_attributes(shipping_address: an_instance_of(FlexCommerce::Address))
      end
    end
    context "main flow" do
      cache = {}
      before(:context) { cache = {} }
      context "with assigned address" do
        before(:context) do
          cache.delete(:created_resource)
          cache.delete(:found_resource)
        end
        let!(:address) { FlexCommerce::Address.create(attributes_for(:address)) }
        before(:each) { cache[:created_resource] ||= model.create(attributes_for(:cart).merge(shipping_address_id: address.id)) }
        context "with included shipping addresses" do
          subject { cache[:found_resource] ||= model.includes(:shipping_address).find(cache[:created_resource].id).first }
          it_behaves_like "any shipping address"
        end
      end

      context "without assigned" do
        before(:context) { cache.delete(:created_resource) }
        before(:each) { cache[:created_resource] ||= model.create(attributes_for(:cart)) }
        context "with included shipping address" do
          before(:context) { cache.delete(:found_resource) }
          subject { cache[:found_resource] ||= model.includes("shipping_address").find(cache[:created_resource].id).first }
          it "should have a nil shipping address" do
            expect(subject.shipping_address).to be_nil
          end
        end
      end
    end


  end
  context "merge" do

  end
end