require "e2e_spec_helper"
RSpec.describe "Taxonomies API end to end spec" do
  it_should_behave_like "crud endpoints", only: [:create, :destroy] do
    let(:base_attributes) { attributes_for(:session) }
    let(:model) { FlexCommerce::Session }
  end
end