# require "rails_helper"
RSpec.describe FlexCommerce::Payments::PaypalExpress::Auth, account: true, speed: :slow, use_transactions: true do
  let(:token) { "fake-token" }
  let(:payer_id) { "fake-payer-id" }
  let(:cart) { build_stubbed(:cart) }
  before(:each) do
    # Ensure the service doesnt touch the cart or its addresses
    cart.shipping_address.freeze
    cart.billing_address.freeze
    cart.freeze
  end

  let(:payment_provider_setup) { instance_spy(::PaymentProviderSetup) }
  let(:payment_provider) { instance_double(::PaymentProvider, reference: "paypal_express_test", service: "paypal_express", test_mode: true, enrichment_hash: {"login" => "login", "password" => "password", "signature" => "signature"}) }
  let(:token) { "fake-token" }
  let(:payer_id) { "fake-payer-id" }
  let(:transaction) { build_stubbed(:payment_transaction, payment_gateway_reference: "paypal_express_test", status: "received", transaction_type: "authorisation", gateway_response: {"token": token, payer_id: payer_id}, container: cart) }
  subject { described_class.new(payment_provider: payment_provider, payment_transaction: transaction) }

  shared_context "mocked active merchant" do |expect_login: true, test_mode: true|
    let(:active_merchant_gateway_class) { class_double("::ActiveMerchant::Billing::PaypalExpressGateway").as_stubbed_const }
    let!(:active_merchant_gateway) { instance_double("::ActiveMerchant::Billing::PaypalExpressGateway") }
    before(:each) do
      expect(active_merchant_gateway_class).to receive(:new).with(test: test_mode, login: payment_provider.enrichment_hash["login"], password: payment_provider.enrichment_hash["password"], signature: payment_provider.enrichment_hash["signature"]).and_return active_merchant_gateway if expect_login
    end
    let(:order_response) do
      instance_double ::ActiveMerchant::Billing::PaypalExpressResponse, "order_response", params: order_response_params, success?: true
    end
    let(:authorize_order_response) do
      instance_double ::ActiveMerchant::Billing::PaypalExpressResponse, "authorize_order_response", params: authorize_order_response_params, success?: true
    end
    let(:order_response_params) do
      {
        "token" => token,
        "Token" => token,
        "transaction_id" => transaction_id,
        "transaction_type" => "express-checkout",
      }
    end
    let(:authorize_order_response_params) do
      {
        "token" => token,
        "Token" => token,
        "transaction_id" => auth_transaction_id,
        "transaction_type" => "express-checkout",
      }
    end

    let(:transaction_id) { "fake-transaction-id" }
    let(:auth_transaction_id) { "fake-auth-transaction-id" }
  end

  context "#call" do
    context "happy path" do
      include_context "mocked active merchant"
      before(:each) { expect(transaction).to receive(:save) } # Transaction saving is the responsbility of the service but not the cart itself
      before(:each) do
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(transaction.amount), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).to receive(:authorize_transaction).with(transaction_id, convert_amount(transaction.amount), transaction_entity: "Order", payer_id: payer_id, currency: "GBP").and_return authorize_order_response
      end

      it "should set the gateway response" do
        subject.call
        expect(transaction.gateway_response).to include("payer_id" => payer_id, "token" => token, "transaction_id" => transaction_id, "authorization_id" => auth_transaction_id)
      end
      it "should set the transaction type" do
        subject.call
        expect(transaction.transaction_type).to eql "authorisation"
      end
      it "should set the transaction status" do
        subject.call
        expect(transaction.status).to eql "success"
      end
      it "should set the transaction tender type" do
        subject.call
        expect(transaction.tender_type).to eql "paypal_express"
      end
    end

    context "happy path in production" do
      include_context "mocked active merchant", test_mode: false
      let(:payment_provider) { instance_double(::PaymentProvider, reference: "paypal_express_test", service: "paypal_express", test_mode: false, enrichment_hash: {"login" => "login", "password" => "password", "signature" => "signature"}) }

      before(:each) { expect(transaction).to receive(:save) } # Transaction saving is the responsbility of the service but not the cart itself
      before(:each) do
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(transaction.amount), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).to receive(:authorize_transaction).with(transaction_id, convert_amount(transaction.amount), transaction_entity: "Order", payer_id: payer_id, currency: "GBP").and_return authorize_order_response
      end

      it "should set the gateway response" do
        subject.call
        expect(transaction.gateway_response).to include("payer_id" => payer_id, "token" => token, "transaction_id" => transaction_id, "authorization_id" => auth_transaction_id)
      end
      it "should set the transaction type" do
        subject.call
        expect(transaction.transaction_type).to eql "authorisation"
      end
      it "should set the transaction status" do
        subject.call
        expect(transaction.status).to eql "success"
      end
      it "should set the transaction tender type" do
        subject.call
        expect(transaction.tender_type).to eql "paypal_express"
      end
    end

    # The fairly happy path is where the service is given bad input but can
    # compromise or somehow recover from it.
    context "fairly happy path" do
      include_context "mocked active merchant", expect_login: false
      before(:each) { expect(transaction).not_to receive(:save) } # All of these examples are unhappy path so save not expected - just gives nicer error message
      before(:each) do
        expect(active_merchant_gateway).not_to receive(:details_for)
        expect(active_merchant_gateway).not_to receive(:order)
        expect(active_merchant_gateway).not_to receive(:authorize_transaction)
      end
      it "should replace the given transaction with the original if a successful authorized transaction already exists for it" do
        expect(transaction).to receive(:reload)
        original_transaction = create :payment_transaction, amount: transaction.amount,
                                                            currency: transaction.currency,
                                                            transaction_type: "authorisation",
                                                            status: "success",
                                                            container_id: cart.id,
                                                            gateway_response: {
                                                              "token" => token,
                                                              "payer_id" => payer_id
                                                            }
        expect(subject.call).to be true
        expect(transaction.id).to eql original_transaction.id
      end
    end

    context "with error scenarios" do
      before(:each) { expect(transaction).not_to receive(:save) } # Transaction saving is the responsbility of the service but not the cart itself
      include_context "mocked active merchant"

      it "should mark the transactions gateway_response as invalid when failure is recoverable in order stage" do
        order_response = instance_double ::ActiveMerchant::Billing::PaypalExpressResponse, "order_response", params: {"error_codes" => "10410", "message" => "Invalid token.", "ack" => "Failure", "Ack" => "Failure"}, success?: false
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(transaction.amount), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).not_to receive(:authorize_transaction)
        expect(subject.call).to be false
        expect(transaction.errors["gateway_response"]).to include "Invalid token"
      end

      it "should mark the transactions gateway_response as invalid when failure is recoverable in auth stage" do
        authorize_order_response = instance_double ::ActiveMerchant::Billing::PaypalExpressResponse, "order_response", params: {"error_codes" => "10410", "message" => "Invalid token.", "ack" => "Failure", "Ack" => "Failure"}, success?: false
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(transaction.amount), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).to receive(:authorize_transaction).with(transaction_id, convert_amount(transaction.amount), transaction_entity: "Order", payer_id: payer_id, currency: "GBP").and_return authorize_order_response
        expect(subject.call).to be false
        expect(transaction.errors["gateway_response"]).to include "Invalid token"
      end

      it "should raise an error when failure is not recoverable in order stage" do
        order_response = instance_double ::ActiveMerchant::Billing::PaypalExpressResponse, "order_response", params: {"error_codes" => "10002", "message" => "Receiving Limit exceeded", "ack" => "Failure", "Ack" => "Failure"}, message: "Receiving limit exceeded", success?: false
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(transaction.amount), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).not_to receive(:authorize_transaction)
        expect { subject.call }.to raise_error Payments::Exception::NotAuthorised
      end

      it "should raise an error when failure is not recoverable in auth stage" do
        authorize_order_response = instance_double ::ActiveMerchant::Billing::PaypalExpressResponse, "order_response", params: {"error_codes" => "10002", "message" => "Receiving Limit exceeded", "ack" => "Failure", "Ack" => "Failure"}, message: "Receiving limit exceeded", success?: false
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(transaction.amount), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).to receive(:authorize_transaction).with(transaction_id, convert_amount(transaction.amount), transaction_entity: "Order", payer_id: payer_id, currency: "GBP").and_return authorize_order_response
        expect {subject.call }.to raise_error Payments::Exception::NotAuthorised
      end
    end
  end

  def convert_amount(amount)
    (amount * 100.0).to_i
  end
end
