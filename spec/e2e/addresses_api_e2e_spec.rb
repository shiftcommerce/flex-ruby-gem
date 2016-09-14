require "e2e_spec_helper"
RSpec.describe "Addresses API end to end spec", vcr: true do
  let(:model) { FlexCommerce::Address }
  context "#create" do
    it "should persist when valid attributes are used" do |example|
      subject = model.create first_name: "First",
                   middle_names: "middle",
                   last_name: "last",
                   address_line_1: "Address line 1",
                   address_line_2: "Address line 2",
                   address_line_3: "Address line 3",
                   city: "City",
                   state: "State",
                   postcode: "Postcode",
                   country: "UK"
      expect(subject).to be_persisted
      expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")

    end
  end
  context "#show" do
    it "should match the schema"
    it "should have the correct values for the attributes"
    it "should have no compound documents if not requested using include"
    context "customer account relationship" do
      it "should have links to the customer account that are accessible"
      it "should have compound documents when requested"
    end

  end
  context "#index" do

  end
  context "#archive" do

  end
  context "#unarchive" do

  end
  context "#destroy" do

  end
end