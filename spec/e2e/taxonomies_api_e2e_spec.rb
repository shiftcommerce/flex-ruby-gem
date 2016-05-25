require "e2e_spec_helper"
RSpec.describe "Taxonomies API end to end spec" do
  it_should_behave_like "crud endpoints", only: [:show] do
    let(:model) { FlexCommerce::Taxonomy }
  end
end