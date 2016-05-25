require "e2e_spec_helper"
RSpec.describe "Line items API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:line_item) }
    let(:attributes_to_update) { { first_name: "#{base_attributes[:first_name]}CHANGED" } }
    let(:model) { FlexCommerce::LineItem }
  end
end