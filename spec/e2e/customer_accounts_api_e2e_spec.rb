require "e2e_spec_helper"
RSpec.describe "Customer Accounts API end to end spec" do
  it_should_behave_like "crud endpoints" do
    let(:base_attributes) { attributes_for(:customer_account) }
    let(:attributes_to_update) { { title: "#{base_attributes[:title]}CHANGED" } }
    let(:model) { FlexCommerce::CustomerAccount }
  end
  context "find by email" do

  end
  context "authenticate" do

  end
  context "generate_token" do

  end
  context "reset_password" do

  end
  context "addresses relationship" do
    #crud
  end
  context "orders relationship" do
    #index and show only
  end
  context "cart relationship" do

  end


end