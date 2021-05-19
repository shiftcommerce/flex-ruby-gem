require "spec_helper"
require "flex_commerce_api"
require "uri"


RSpec.describe "OMS Order History" do
  include_context "global context"

  let(:subject_class) { ::FlexCommerce::CustomerOrder }

  context "Fetching Order history via OMS" do
    subject_class.fetch_orders(customer_reference: "12345")
  end
end