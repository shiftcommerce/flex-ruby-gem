require "e2e_spec_helper"
RSpec.describe "Ewis Opt Ins API end to end spec" do
  it_should_behave_like "crud endpoints", only: [:create, :show] do
    let(:base_attributes) { attributes_for(:ewis_opt_in) }
    let(:model) { FlexCommerce::EwisOptIn }
  end
end