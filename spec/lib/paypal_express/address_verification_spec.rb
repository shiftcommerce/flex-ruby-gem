require "e2e_spec_helper"

RSpec.describe FlexCommerce::PaypalExpress::AddressVerification, vcr: true, paypal: true do
  include_context "context store"
  include_context "housekeeping"

  let(:verify_address_params) do
    {
      email: cart.email,
      address: {
        address1: instance_of(String),
        zip: instance_of(String)
      }
    }
  end
  # Mock active merchant
  let!(:active_merchant_gateway_class) { class_double("ActiveMerchant::Billing::PaypalExpressGateway", new: active_merchant_gateway).as_stubbed_const }
  let!(:active_merchant_gateway) { instance_double("ActiveMerchant::Billing::PaypalExpressGateway") }

  subject { described_class.new(cart: cart) }

  # As we are not testing the paypal service itself, we are only interested in what happens
  # when specific canned paypal responses are returned from the mocks, then the inputs to
  # all examples are the same - see below
  let(:cart) { create(:cart, email: "test@mydomain.com", shipping_address: shipping_address) }
  let(:shipping_address) do
    to_clean.shipping_address ||= FlexCommerce::Address.create(first_name: 'First Name', last_name: 'Last name', address_line_1: 'Address line 1', city: 'Leeds', country: 'GB', postcode: 'LS10 1QN')
  end

  let(:address_attributes) { attributes_for(:address) }

  context "#call" do
    context "with valid address" do
      before(:each) do
        expect(active_merchant_gateway).to receive(:verify_address).with(verify_address_params).and_return verify_address_response
      end
      let(:verify_address_response) do
        instance_double "ActiveMerchant::Billing::PaypalExpressResponse", "address_verification", success?: true, params: {
          "AddressVerifyResponse" => {
            "Ack" => "Success",
            "ConfirmationCode" => "Confirmed",
            "StreetMatch" => "Matched",
            "ZipMatch" => "Matched"
          }
        }
      end

      it "should not add any errors to to the address verification object" do
        response = subject.call
        expect(response[:errors]).to be_empty
      end

      it "should modify the gateway response of the transaction and save it" do
        response = subject.call
        expect(response[:gateway_response]).to include(address_verification_confirmation_code: "Confirmed", address_verification_ack: "Success")
      end
    end
    context "with invalid address" do
      before(:each) do
        expect(active_merchant_gateway).to receive(:verify_address).with(verify_address_params).and_return verify_address_response
      end

      let(:verify_address_response) do
        instance_double "ActiveMerchant::Billing::PaypalExpressResponse", "address_verification", success?: true, params: {
            "AddressVerifyResponse" => {
                "Ack" => "Success",
                "ConfirmationCode" => "Unconfirmed",
                "StreetMatch" => "Unmatched",
                "ZipMatch" => "Unmatched"
            }
        }
      end

      it "should add errors to to the address verification object" do
        response = subject.call
        expect(response[:errors]).not_to be_empty
      end

      it "should modify the gateway response of the transaction and save it" do
        response = subject.call
        expect(response[:gateway_response]).to include(address_verification_confirmation_code: "Unconfirmed", address_verification_ack: "Success")
      end

    end
    context "with invalid email address" do
      before(:each) do
        expect(active_merchant_gateway).to receive(:verify_address).with(verify_address_params).and_return verify_address_response
      end

      let(:verify_address_response) do
        instance_double "ActiveMerchant::Billing::PaypalExpressResponse", "address_verification", success?: true, params: {
          "AddressVerifyResponse" => {
            "Ack" => "Success",
            "ConfirmationCode" => "None",
            "StreetMatch" => "None",
            "ZipMatch" => "None"
          }
        }
      end
    end
    context "with paypal account not configured" do
      before(:each) do
        expect(active_merchant_gateway).to receive(:verify_address).with(verify_address_params).and_return verify_address_response
      end

      let(:verify_address_response) do
        instance_double "ActiveMerchant::Billing::PaypalExpressResponse", "address_verification", success?: false, params: {
          "AddressVerifyResponse" => {
            "Ack" => "Failure",
            "ConfirmationCode" => "None",
            "StreetMatch" => "None",
            "ZipMatch" => "None",
            "Errors" => {
              "ShortMessage" => "Authentication/Authorization Failed",
              "LongMessage" => "You do not have permissions to make this API call",
              "ErrorCode" => 10002,
              "SeverityCode" => "Error"
            }
          }
        }
      end
    end
  end
end