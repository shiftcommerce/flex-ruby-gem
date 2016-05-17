require "e2e_spec_helper"
RSpec.describe "Asset Folders API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:asset_folder) }
    let(:attributes_to_update) { { name: "#{base_attributes[:name]}CHANGED" } }
    let(:model) { FlexCommerce::AssetFolder }
  end
end