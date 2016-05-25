require "e2e_spec_helper"
RSpec.describe "Data attributes API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:data_attribute) }
    let(:attributes_to_update) { { name: "#{base_attributes[:name]}CHANGED" } }
    let(:model) { FlexCommerce::DataAttribute }
  end
end