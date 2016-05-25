require "e2e_spec_helper"
RSpec.describe "Asset Files API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:asset_file) }
    let(:attributes_to_update) { { name: "#{base_attributes[:name]}CHANGED" } }
    let(:model) { FlexCommerce::AssetFile }
  end
  context "bulk import" do

  end
  context "bulk delete" do

  end
  context "versions" do

  end
  context "restore" do

  end

end