# frozen_string_literal: true
require "rails_helper"
RSpec.describe Payments::PaymentProcessor, speed: :slow do
  context "#call", account: true do
    let!(:auth_middleware_class) { class_double(::Payments::PaymentProcess::Middleware::Auth).as_stubbed_const }
    let!(:create_order_middleware_class) { class_double(::Payments::PaymentProcess::Middleware::CreateOrder).as_stubbed_const }
    let!(:apply_promotions_middleware_class) { class_double(::Payments::PaymentProcess::Middleware::ApplyPromotions).as_stubbed_const }
    let(:auth_middleware) { instance_spy(::Payments::PaymentProcess::Middleware::Auth) }
    let(:create_order_middleware) { instance_spy(::Payments::PaymentProcess::Middleware::CreateOrder) }
    let(:apply_promotions_middleware) { instance_spy(::Payments::PaymentProcess::Middleware::ApplyPromotions) }
    let(:cart) { create(:cart, :with_line_items, line_items_count: 2) }
    let(:fake_token) { "fake-token" }
    let(:fake_payer_id) { "fake-payer-id" }
    let(:transaction) { build(:payment_transaction) }
    let!(:payment_provider) { create(:payment_provider, :paypal_express, reference: "paypal_express_test") }
    context "without any extras" do
      let(:fake_payment_process) do
        create :payment_process, cart_id: cart.id,
                                        payment_gateway_reference: "paypal_express_test",
                                        payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id }
      end
      before(:each) { allow(fake_payment_process).to receive(:save) }  # As progress reporting attempts to save
      subject { described_class.new(payment_process: fake_payment_process) }

      it "should call the apply_promotions, auth and create_order middlewares only" do
        expect(apply_promotions_middleware_class).to receive(:new).and_return apply_promotions_middleware
        expect(auth_middleware_class).to receive(:new).and_return auth_middleware
        expect(create_order_middleware_class).to receive(:new).and_return create_order_middleware
        expect(apply_promotions_middleware).to receive(:call)
        expect(auth_middleware).to receive(:call)
        expect(create_order_middleware).to receive(:call)
        subject.call
      end

      it "should setup each middleware with the same objects as the first" do
        passed_state = nil
        expect(apply_promotions_middleware_class).to receive(:new) do |payment_process:, state:|
          passed_state = state
          expect(payment_process).to be fake_payment_process
          apply_promotions_middleware
        end
        expect(auth_middleware_class).to receive(:new) do |payment_process:, state:|
          passed_state = state
          expect(payment_process).to be fake_payment_process
          auth_middleware
        end
        expect(create_order_middleware_class).to receive(:new) do |payment_process:, state:|
          expect(state).to be passed_state
          expect(payment_process).to be fake_payment_process
          create_order_middleware
        end
        allow(apply_promotions_middleware).to receive(:call).and_return true
        allow(auth_middleware).to receive(:call).and_return true
        allow(create_order_middleware).to receive(:call).and_return true
        subject.call
      end
    end

    context "with post_processes " do
      let!(:middleware_1_class) { class_double("Payments::PaymentProcess::Middleware::Middleware1").as_stubbed_const }
      let(:middleware_1) { instance_double("Payments::PaymentProcess::Middleware::Middleware1") }
      let!(:middleware_2_class) { class_double("Payments::PaymentProcess::Middleware::Middleware2").as_stubbed_const }
      let(:middleware_2) { instance_double("Payments::PaymentProcess::Middleware::Middleware2") }
      let(:fake_payment_process) do
        create :payment_process, cart_id: cart.id,
                                        payment_gateway_reference: "paypal_express_test",
                                        payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id },
                                        post_processes: ["middleware_1", "middleware_2"]
      end
      before(:each) { allow(fake_payment_process).to receive(:save) }  # As progress reporting attempts to save
      subject { described_class.new(payment_process: fake_payment_process) }

      it "should call the basic middlewares followed by the post processes in the correct order" do
        passed_state = nil
        create_order_middleware_ran = false
        middleware_1_ran = false
        middleware_2_ran = false
        expect(apply_promotions_middleware_class).to receive(:new) do |payment_process:, state:|
          passed_state = state
          expect(payment_process).to be fake_payment_process
          apply_promotions_middleware
        end
        expect(auth_middleware_class).to receive(:new) do |payment_process:, state:|
          passed_state = state
          expect(payment_process).to be fake_payment_process
          auth_middleware
        end
        expect(create_order_middleware_class).to receive(:new).and_return(create_order_middleware)
        expect(middleware_1_class).to receive(:new) do |payment_process:, state:|
          expect(state).to be passed_state
          expect(payment_process).to be fake_payment_process
          middleware_1
        end
        expect(middleware_2_class).to receive(:new) do |payment_process:, state:|
          expect(state).to be passed_state
          expect(payment_process).to be fake_payment_process
          middleware_2
        end
        expect(apply_promotions_middleware).to receive(:call).and_return true
        expect(auth_middleware).to receive(:call).and_return true
        expect(create_order_middleware).to receive(:call) do
          create_order_middleware_ran = true
        end
        expect(middleware_1).to receive(:call) do
          expect(create_order_middleware_ran).to be true
          expect(middleware_2_ran).to be false
          middleware_1_ran = true
        end
        expect(middleware_2).to receive(:call) do
          expect(create_order_middleware_ran).to be true
          expect(middleware_1_ran).to be true
          middleware_2_ran = true
        end
        subject.call
      end
    end

    context "with additional processes" do
      let!(:middleware_1_class) { class_double("Payments::PaymentProcess::Middleware::Middleware1").as_stubbed_const }
      let(:middleware_1) { instance_double("Payments::PaymentProcess::Middleware::Middleware1") }
      let!(:middleware_2_class) { class_double("Payments::PaymentProcess::Middleware::Middleware2").as_stubbed_const }
      let(:middleware_2) { instance_double("Payments::PaymentProcess::Middleware::Middleware2") }
      let(:fake_payment_process) do
        create :payment_process, cart_id: cart.id,
                                        payment_gateway_reference: "paypal_express_test",
                                        payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id },
                                        additional_processes: ["middleware_1", "middleware_2"]
      end
      before(:each) { allow(fake_payment_process).to receive(:save) }  # As progress reporting attempts to save
      subject { described_class.new(payment_process: fake_payment_process) }

      it "should call the basic middlewares followed by the post processes in the correct order" do
        passed_state = nil
        create_order_middleware_ran = false
        middleware_1_ran = false
        middleware_2_ran = false
        expect(apply_promotions_middleware_class).to receive(:new) do |payment_process:, state:|
          passed_state = state
          expect(payment_process).to be fake_payment_process
          apply_promotions_middleware
        end
        expect(auth_middleware_class).to receive(:new) do |payment_process:, state:|
          passed_state = state
          expect(payment_process).to be fake_payment_process
          auth_middleware
        end
        expect(create_order_middleware_class).to receive(:new).and_return(create_order_middleware)
        expect(middleware_1_class).to receive(:new) do |payment_process:, state:|
          expect(state).to be passed_state
          expect(payment_process).to be fake_payment_process
          middleware_1
        end
        expect(middleware_2_class).to receive(:new) do |payment_process:, state:|
          expect(state).to be passed_state
          expect(payment_process).to be fake_payment_process
          middleware_2
        end
        expect(apply_promotions_middleware).to receive(:call).and_return true
        expect(auth_middleware).to receive(:call).and_return true
        expect(create_order_middleware).to receive(:call) do
          expect(middleware_1_ran).to be true
          expect(middleware_2_ran).to be true
          create_order_middleware_ran = true
        end
        expect(middleware_1).to receive(:call) do
          expect(create_order_middleware_ran).to be false
          expect(middleware_2_ran).to be false
          middleware_1_ran = true
        end
        expect(middleware_2).to receive(:call) do
          expect(create_order_middleware_ran).to be false
          expect(middleware_1_ran).to be true
          middleware_2_ran = true
        end
        subject.call
      end
    end

    context "exception handling" do
      let(:payment_process) do
        create :payment_process, cart_id: cart.id,
                                        payment_gateway_reference: "paypal_express_test",
                                        payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id }
      end
      subject { described_class.new(payment_process: payment_process) }
      it "should catch and re raise errors whilst increasing retry count" do
        expect(apply_promotions_middleware_class).to receive(:new).and_return apply_promotions_middleware
        ex = StandardError.new("Any old message")
        expect(apply_promotions_middleware).to receive(:call) do
          raise ex
        end
        expect(payment_process).to receive(:process_retry).with(ex)
        expect { subject.call }.to raise_error(ex)
      end
    end
  end
end
