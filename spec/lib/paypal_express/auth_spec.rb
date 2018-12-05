require "e2e_spec_helper"

RSpec.describe FlexCommerce::PaypalExpress::Auth, vcr: true, paypal: true do
  include ActiveSupport::NumberHelper
  include_context "context store"
  include_context "housekeeping"
  
  let(:token) { "fake-token" }
  let(:payer_id) { "fake-payer-id" }
  let(:cart) { build_stubbed(:cart, total: 100) }
  let(:transaction) { 
    to_clean.transaction = FlexCommerce::PaymentTransaction.create(
      cart_id: cart.id,
      gateway_response: {
        token: token,
        payer_id: payer_id
      },
      amount: cart.total,
      status: "success",
      transaction_type: 'authorisation',
      currency: "GBP",
      payment_gateway_reference: "paypal_reference"
    )
  }
  before(:each) do
    # Ensure the service doesnt touch the cart or its addresses
    cart.shipping_address.freeze
    cart.billing_address.freeze
    cart.freeze
  end
  
  subject { described_class.new(cart: cart, token: token, payer_id: payer_id, payment_transaction: transaction) }

  shared_context "mocked active merchant" do |expect_login: true, test_mode: true|
    # Mock active merchant
    let(:active_merchant_gateway_class) { class_double("ActiveMerchant::Billing::PaypalExpressGateway", new: active_merchant_gateway).as_stubbed_const }
    let(:active_merchant_gateway) { instance_spy("ActiveMerchant::Billing::PaypalExpressGateway") }
    let!(:active_connection_error) { class_double("ActiveMerchant::ConnectionError").as_stubbed_const }

    before(:each) do
      expect(active_merchant_gateway_class).to receive(:new).with(test: true, login: ENV['PAYPAL_LOGIN'], password: ENV['PAYPAL_PASSWORD'], signature: ENV['PAYPAL_SIGNATURE']).and_return active_merchant_gateway if expect_login
    end
    let(:order_response) do
      instance_double "ActiveMerchant::Billing::PaypalExpressResponse", "order_response", params: order_response_params, success?: true
    end
    let(:authorize_order_response) do
      instance_double "ActiveMerchant::Billing::PaypalExpressResponse", "authorize_order_response", params: authorize_order_response_params, success?: true
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

      before(:each) do
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(cart.total), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).to receive(:authorize_transaction).with(transaction_id, convert_amount(cart.total), transaction_entity: "Order", payer_id: payer_id, currency: "GBP").and_return authorize_order_response
      end

      it "should set the gateway response" do
        response = subject.call
        expect(response.gateway_response).to include(transaction_id: transaction_id, authorization_id: auth_transaction_id)
      end

    end

    context "happy path in production" do
      include_context "mocked active merchant", test_mode: false
      
      before(:each) do
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(cart.total), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).to receive(:authorize_transaction).with(transaction_id, convert_amount(cart.total), transaction_entity: "Order", payer_id: payer_id, currency: "GBP").and_return authorize_order_response
      end

      it "should set the gateway response" do
        response = subject.call
        expect(response.gateway_response).to include(transaction_id: transaction_id, authorization_id: auth_transaction_id)
      end
    end

    context "with error scenarios" do
      include_context "mocked active merchant"
      
      it "should mark the transactions gateway_response as invalid when failure is recoverable in order stage" do
        order_response = instance_double "ActiveMerchant::Billing::PaypalExpressGateway", "order_response", params: {"error_codes" => "10410", "message" => "Invalid token.", "ack" => "Failure", "Ack" => "Failure"}, success?: false
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(cart.total), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).not_to receive(:authorize_transaction)
        response = subject.call
        expect(response[0]["gateway_response"]).to include "Invalid token"
      end

      it "should mark the transactions gateway_response as invalid when failure is recoverable in auth stage" do
        authorize_order_response = instance_double "ActiveMerchant::Billing::PaypalExpressGateway", "order_response", params: {"error_codes" => "10410", "message" => "Invalid token.", "ack" => "Failure", "Ack" => "Failure"}, success?: false
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(cart.total), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).to receive(:authorize_transaction).with(transaction_id, convert_amount(cart.total), transaction_entity: "Order", payer_id: payer_id, currency: "GBP").and_return authorize_order_response
        response = subject.call
        expect(response[0]["gateway_response"]).to include "Invalid token"
      end

      it "should raise an error when failure is not recoverable in order stage" do
        order_response = instance_double "ActiveMerchant::Billing::PaypalExpressGateway", "order_response", params: {"error_codes" => "10002", "message" => "Receiving Limit exceeded", "ack" => "Failure", "Ack" => "Failure"}, message: "Receiving limit exceeded", success?: false
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(cart.total), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).not_to receive(:authorize_transaction)
        expect { subject.call }.to raise_error ::FlexCommerce::PaypalExpress::Exception::NotAuthorized
      end

      it "should raise an error when failure is not recoverable in auth stage" do
        authorize_order_response = instance_double "ActiveMerchant::Billing::PaypalExpressGateway", "authorize_order_response", params: {"error_codes" => "10002", "message" => "Receiving Limit exceeded", "ack" => "Failure", "Ack" => "Failure"}, message: "Receiving limit exceeded", success?: false
        expect(active_merchant_gateway).to receive(:order).with(convert_amount(cart.total), token: token, payer_id: payer_id, currency: "GBP").and_return order_response
        expect(active_merchant_gateway).to receive(:authorize_transaction).with(transaction_id, convert_amount(cart.total), transaction_entity: "Order", payer_id: payer_id, currency: "GBP").and_return authorize_order_response
        expect { subject.call }.to raise_error ::FlexCommerce::PaypalExpress::Exception::NotAuthorized
      end
    end
  end

  def convert_amount(amount)
    (amount * 100.0).to_i
  end
end
