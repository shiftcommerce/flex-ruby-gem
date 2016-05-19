require "e2e_spec_helper"
RSpec.describe "Menus API end to end spec" do
  it_should_behave_like "crud endpoints", only: [:index, :show] do
    let(:model) { FlexCommerce::Menu }
  end
  context "restore" do

  end
  context "versions" do

  end
end