require "e2e_spec_helper"
RSpec.describe "Variants API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:variant) }
    let(:attributes_to_update) { { title: "#{base_attributes[:title]}CHANGED" } }
    let(:model) { FlexCommerce::Variant }
  end
  context "related products" do

  end
  context "related asset files" do

  end
  context "related markdown prices" do

  end
  context "bulk import" do

  end
  context "bulk delete" do

  end


end