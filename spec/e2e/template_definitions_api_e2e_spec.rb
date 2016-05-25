require "e2e_spec_helper"
RSpec.describe "Template definitions API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:template_definition) }
    let(:attributes_to_update) { { name: "#{base_attributes[:name]}CHANGED" } }
    let(:model) { FlexCommerce::TemplateDefinition }
  end
  context "versions" do

  end
  context "restore" do

  end

end