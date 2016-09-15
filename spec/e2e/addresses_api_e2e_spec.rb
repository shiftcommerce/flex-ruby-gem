require "e2e_spec_helper"
RSpec.describe "Addresses API end to end spec", vcr: true do
  _created_id = nil
  _created_customer_account_id = nil
  let(:model) { FlexCommerce::Address }
  let(:created_id) { _created_id }
  let(:created_customer_account_id) { _created_customer_account_id }
  context "#create" do
    before(:context) do
      VCR.use_cassette "temp" do
        _created_customer_account_id = FlexCommerce::CustomerAccount.create!(email: "testaccount#{Time.now.to_f}@domain.com", reference: "ref_#{Time.now.to_f}", password: "12345test67890").id
        http_request_tracker.clear
      end
    end
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
                   country: "UK",
                   customer_account_id: created_customer_account_id
      expect(subject).to be_persisted
      _created_id = subject.id
      expect(http_request_tracker.first[:response]).to match_response_schema("jsonapi/schema")
      expect(http_request_tracker.first[:response]).to match_response_schema("shift/v1/documents/member/address")

    end
  end
  context "#show" do
    it "should match the schema"
    it "should have the correct values for the attributes"
    it "should have no compound documents if not requested using include"
    context "customer account relationship" do
      it "should have links to the customer account that are accessible"
      it "should have compound documents when requested" do
        subject = model.includes("customer_account").find(created_id).first
        expect(subject.id).to eql created_id
      end
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