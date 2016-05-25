require "e2e_spec_helper"
RSpec.describe "Category Trees API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:category_tree) }
    let(:attributes_to_update) { { title: "#{base_attributes[:title]}CHANGED" } }
    let(:model) { FlexCommerce::CategoryTree }
  end

end