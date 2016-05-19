require "e2e_spec_helper"
RSpec.describe "Shipping Methods API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:shipping_method) }
    let(:attributes_to_update) { { name: "#{base_attributes[:name]}CHANGED" } }
    let(:model) { FlexCommerce::ShippingMethod }
  end
end