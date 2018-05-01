require "rails_helper"
RSpec.describe Payments::PaypalExpress::AddressVerification, account: true do
  let(:verify_address_params) do
    {
        email: address_verification.email,
        address: {
            address1: instance_of(String),
            zip: instance_of(String)
        }
    }
  end
  # Mock active merchant
  let!(:active_merchant_gateway_class) { class_double("::ActiveMerchant::Billing::PaypalExpressGateway", new: active_merchant_gateway).as_stubbed_const }
  let!(:active_merchant_gateway) { instance_double("::ActiveMerchant::Billing::PaypalExpressGateway") }

  # Mock the payment provider
  let!(:payment_provider_class) { class_double(::PaymentProvider).as_stubbed_const }
  let(:payment_provider) { instance_double(::PaymentProvider, test_mode: true, reference: "paypal_express_test", service: "paypal_express", enrichment_hash: { "login" => "login", "password" => "password", "signature" => "signature" }) }

  subject { described_class.new(address_verification: address_verification, payment_provider: PaymentProvider.find_by(reference: "paypal_express_test")) }

  # As we are not testing the paypal service itself, we are only interested in what happens
  # when specific canned paypal responses are returned from the mocks, then the inputs to
  # all examples are the same - see below
  let(:address_verification) { build :payment_address_verification, transaction_id: transaction.id, address_attributes: address_attributes, email: "test@mydomain.com" }
  let(:cart) { create(:cart) }
  let(:transaction) { create(:payment_transaction, payment_gateway_reference: "paypal_express_test", container_id: cart.id) }
  let(:address_attributes) { attributes_for(:address) }

  # All examples must find the payment provider to get the paypal credentials
  before(:each) do
    expect(payment_provider_class).to receive(:find_by).with(reference: "paypal_express_test").and_return payment_provider
  end

  context "#call" do
    context "with valid address" do
      before(:each) do
        expect(active_merchant_gateway).to receive(:verify_address).with(verify_address_params).and_return verify_address_response
      end
      let(:verify_address_response) do
        instance_double ::ActiveMerchant::Billing::PaypalExpressResponse, "address_verification", success?: true, params: {
            "AddressVerifyResponse" => {
                "Ack" => "Success",
                "ConfirmationCode" => "Confirmed",
                "StreetMatch" => "Matched",
                "ZipMatch" => "Matched"
            }
        }
      end

      it "should not add any errors to to the address verification object" do
        subject.call
        expect(address_verification.errors).to be_empty
      end

      it "should modify the gateway response of the transaction and save it" do
        subject.call
        expect(transaction.reload.gateway_response).to include("address_verification_confirmation_code" => "Confirmed", "address_verification_ack" => "Success")
      end
    end
    context "with invalid address" do
      before(:each) do
        expect(active_merchant_gateway).to receive(:verify_address).with(verify_address_params).and_return verify_address_response
      end

      let(:verify_address_response) do
        instance_double ::ActiveMerchant::Billing::PaypalExpressResponse, "address_verification", success?: true, params: {
            "AddressVerifyResponse" => {
                "Ack" => "Success",
                "ConfirmationCode" => "Unconfirmed",
                "StreetMatch" => "Unmatched",
                "ZipMatch" => "Unmatched"
            }
        }
      end

      it "should add errors to to the address verification object" do
        subject.call
        expect(address_verification.errors).not_to be_empty
      end

      it "should modify the gateway response of the transaction and save it" do
        subject.call
        expect(transaction.reload.gateway_response).to include("address_verification_confirmation_code" => "Unconfirmed", "address_verification_ack" => "Success")
      end

    end
    context "with invalid email address" do
      before(:each) do
        expect(active_merchant_gateway).to receive(:verify_address).with(verify_address_params).and_return verify_address_response
      end

      let(:verify_address_response) do
        instance_double ::ActiveMerchant::Billing::PaypalExpressResponse, "address_verification", success?: true, params: {
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
        instance_double ::ActiveMerchant::Billing::PaypalExpressResponse, "address_verification", success?: false, params: {
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
