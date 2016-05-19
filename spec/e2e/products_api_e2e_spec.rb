require "e2e_spec_helper"
RSpec.describe "Products API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:product) }
    let(:attributes_to_update) { { title: "#{base_attributes[:title]}CHANGED" } }
    let(:model) { FlexCommerce::Product }
  end
  context "search" do

  end
  context "product asset files relationship" do

  end
  context "variants relationship" do

  end
  context "bulk import" do

  end
  context "bulk delete" do

  end


end