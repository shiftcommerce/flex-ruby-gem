# frozen_string_literal: true
# require "rails_helper"
RSpec.describe Payments::PaymentProcess::Middleware::Auth do
  context "#call", account: true, use_real_elastic_search: false do
    let!(:auth_service_class) { class_double(Payments::Auth).as_stubbed_const }
    let(:auth_service) { instance_spy(Payments::Auth) }
    let(:cart) { create(:cart, :with_line_items, line_items_count: 2) }
    let(:fake_token) { "fake-token" }
    let(:fake_payer_id) { "fake-payer-id" }
    let(:state) { OpenStruct.new }

    context "a simple order to be authorised" do
      let!(:payment_provider) { create(:payment_provider, :paypal_express, reference: "paypal_express_test") }
      let(:payment_process) do
        create :payment_process, cart_id: cart.id,
                                        payment_gateway_reference: "paypal_express_test",
                                        payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id }
      end

      around(:each) do |example|
        Subscribers.for(context: :web) do
          example.run
        end
      end

      before(:each) { allow(payment_process).to receive(:save) }
      subject { described_class.new(payment_process: payment_process, state: state) }

      it "should call the auth service to authorise the transaction", speed: :slow do
        transaction = nil
        expect(auth_service_class).to receive(:new) do |payment_transaction:|
          transaction = payment_transaction
          expect(payment_transaction).to be_a(PaymentTransaction)
          expect(payment_transaction).to have_attributes payment_gateway_reference: "paypal_express_test",
                                                         status: "received",
                                                         transaction_type: "authorisation",
                                                         amount: cart.total,
                                                         container_id: cart.id,
                                                         gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id }
          auth_service
        end
        expect(auth_service).to receive(:call).once do
          # Emulate what the real service would do - otherwise order wont be accepted
          transaction.update status: PaymentTransaction::STATUS_SUCCESS,
                             amount: cart.total,
                             currency: "GBP",
                             gateway_response: { "auth_id" => "somerandomthing", "payer_id" => fake_payer_id }
        end
        subject.call
      end

      it "should set the state correctly", speed: :slow do
        transaction = nil
        expect(auth_service_class).to receive(:new) do |payment_transaction:|
          transaction = payment_transaction
          expect(payment_transaction).to be_a(PaymentTransaction)
          expect(payment_transaction).to have_attributes payment_gateway_reference: "paypal_express_test",
                                                         status: "received",
                                                         transaction_type: "authorisation",
                                                         amount: cart.total,
                                                         container_id: cart.id,
                                                         gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id }
          auth_service
        end
        expect(auth_service).to receive(:call).once.and_return true
        subject.call
        expect(state.transaction).to be transaction
        expect(state.message).to eql(:authorised).or eql("authorised")
        expect(state.status).to eql(:authorised).or eql("authorised")
      end
    end

    context "a simple order that gets called twice for same cart", speed: :slow do
      let!(:payment_provider) { create(:payment_provider, :paypal_express, reference: "paypal_express_test") }
      subject { described_class.new(payment_process: payment_process, state: state) }
      let(:payment_process) do
        build :payment_process, cart_id: cart.id,
                                payment_gateway_reference: "paypal_express_test",
                                payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id }
      end
      let(:second_state) { OpenStruct.new }
      let(:second_subject) { described_class.new(payment_process: PaymentProcess.find(payment_process.id), state: second_state) }

      around(:each) do |example|
        Subscribers.for(context: :web) do
          example.run
        end
      end

      it "should only auth once if called twice", speed: :slow do
        transaction = nil
        expect(auth_service_class).to receive(:new).once do |payment_transaction:|
          transaction = payment_transaction
          expect(payment_transaction).to be_a(PaymentTransaction)
          expect(payment_transaction).to have_attributes payment_gateway_reference: "paypal_express_test",
                                                         status: "received",
                                                         transaction_type: "authorisation",
                                                         amount: cart.total,
                                                         container_id: cart.id,
                                                         gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id }
          auth_service
        end
        expect(auth_service).to receive(:call).once.and_return true
        subject.call
        second_subject.call
        expect(second_state.transaction.id).to eql transaction.id
        expect(second_state.message).to eql(:authorised).or eql("authorised")
        expect(second_state.status).to eql(:authorised).or eql("authorised")
      end
    end

    context "a simple order whose transaction contains errors so cannot be paid for" do
      let!(:payment_provider) { create(:payment_provider, :paypal_express, reference: "paypal_express_test") }
      let(:payment_process) do
        create :payment_process, cart_id: cart.id,
                                        payment_gateway_reference: "paypal_express_test",
                                        payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id }
      end

      around(:each) do |example|
        Subscribers.for(context: :web) do
          example.run
        end
      end

      before(:each) { allow(payment_process).to receive(:save) }
      subject { described_class.new(payment_process: payment_process, state: state) }

      it "should throw :abort with errors populated in payment_process when errors are from payment system", speed: :slow do
        transaction = nil
        expect(auth_service_class).to receive(:new) do |payment_transaction:|
          transaction = payment_transaction
          auth_service
        end
        expect(auth_service).to receive(:call) do
          # Populate errors like the real service would do in the case of failure
          transaction.errors.add(:gateway_response, "Invalid token")
        end

        expect { subject.call }.to throw_symbol(:abort, false)
        expect(payment_process.validation_errors).to include("gateway_response" => a_collection_including("Invalid token"))
        expect(payment_process.status).to eql "invalid"
      end

      it "should throw an exception when errors are from transaction validation not payment gateway", speed: :slow do
        transaction = nil
        expect(auth_service_class).to receive(:new) do |payment_transaction:|
          transaction = payment_transaction
          auth_service
        end
        expect(auth_service).to receive(:call) do
          # Populate errors like the real service would do in the case of failure
          transaction.errors.add(:amount, "Must be greater than zero")
        end

        expect { subject.call }.to raise_error(Payments::Exception::NotAuthorised)
      end
    end
  end
end
