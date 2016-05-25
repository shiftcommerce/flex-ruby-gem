require "e2e_spec_helper"
RSpec.describe "ProductBulkExports API end to end spec" do
  it_should_behave_like "crud endpoints", only: [:create, :show] do
    let(:base_attributes) { attributes_for(:product_bulk_export) }
    let(:model) { FlexCommerce::ProductBulkExport }
  end
end