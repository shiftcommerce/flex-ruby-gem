require "e2e_spec_helper"
RSpec.describe "CustomerAccountBulkExports API end to end spec" do
  it_should_behave_like "crud endpoints", only: [:create, :show] do
    let(:base_attributes) { attributes_for(:customer_account_bulk_export) }
    let(:model) { FlexCommerce::CustomerAccountBulkExport }
  end
end