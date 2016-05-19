require "e2e_spec_helper"
RSpec.describe "Payment provider setups API end to end spec" do
  it_should_behave_like "crud endpoints", only: [:create] do
    let(:base_attributes) { attributes_for(:payment_provider_setup) }
    let(:model) { FlexCommerce::PaymentProviderSetup }
  end
end