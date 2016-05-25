require "e2e_spec_helper"
RSpec.describe "Static Pages API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:static_page) }
    let(:attributes_to_update) { { title: "#{base_attributes[:title]}CHANGED" } }
    let(:model) { FlexCommerce::StaticPage }
  end

  context "versions" do

  end
  context "restore" do

  end

end