require "e2e_spec_helper"
RSpec.describe "Refunds API end to end spec" do
  it_should_behave_like "crud endpoints", only: [:create] do
    let(:base_attributes) { attributes_for(:refund) }
    let(:model) { FlexCommerce::Refund }
  end
end