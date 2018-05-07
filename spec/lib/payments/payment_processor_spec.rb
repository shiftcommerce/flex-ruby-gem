# frozen_string_literal: true
require "spec_helper"
require "flex_commerce_api"
require "e2e_spec_helper"

module FlexCommerce
  module Payments
    describe PaymentProcessor,vcr: true do
      include_context "context store"
      include_context "housekeeping"
      context "#call" do

        # Stubbed data
        let!(:auth_middleware_class) { class_double("Payments::PaymentProcess::Middleware::Auth").as_stubbed_const }
        let!(:create_order_middleware_class) { class_double("Payments::PaymentProcess::Middleware::CreateOrder").as_stubbed_const }
        let!(:apply_promotions_middleware_class) { class_double("Payments::PaymentProcess::Middleware::ApplyPromotions").as_stubbed_const }
        let(:auth_middleware) { instance_spy("Payments::PaymentProcess::Middleware::Auth") }
        let(:create_order_middleware) { instance_spy("Payments::PaymentProcess::Middleware::CreateOrder") }
        let(:apply_promotions_middleware) { instance_spy("Payments::PaymentProcess::Middleware::ApplyPromotions") }
        let(:fake_token) { "fake-token" }
        let(:fake_payer_id) { "fake-payer-id" }

        # Prepare cart data
        let(:uuid) { SecureRandom.uuid }
        let(:global_product) do
          to_clean.global_product ||= FlexCommerce::Product.create!(title: "Title for product 1 for variant #{uuid}",
                                                                    reference: "reference for product 1 for variant #{uuid}",
                                                                    content_type: "markdown").freeze
        end

        let(:global_variant) do
          to_clean.global_variant ||= FlexCommerce::Variant.create(title: "Title for Test Variant #{uuid}",
            description: "Description for Test Variant #{uuid}",
            reference: "reference_for_test_variant_#{uuid}",
            price: 5.50,
            price_includes_taxes: false,
            sku: "sku_for_test_variant_#{uuid}",
            product_id: global_product.id).freeze
        end

        let(:line_items) do
          to_clean.line_items ||= FlexCommerce::LineItem.create(item_id: global_variant.id, unit_quantity: 2, item_type: 'Variant')
        end

        let(:global_cart) do
          to_clean.global_cart ||= FlexCommerce::Cart.find(line_items.container_id)
        end
  
        # Transaction data
        let(:transaction) do
          to_clean.transaction ||= FlexCommerce::PaymentTransaction.create(cart_id: global_cart.id,
            gateway_response: {
              token: fake_token,
              transaction_id: fake_payer_id
            },
            amount: global_cart.total,
            currency: 'GBP',
            transaction_type: "authorisation",
            status: "success",
            payment_gateway_reference: "paypal_here")
        end
        let!(:payment_provider) do
          to_clean.payment_provider ||= FlexCommerce::PaymentProcess.create reference: "paypal_express_test"
        end

        context "without any extras" do
          # Fake payment process
          let(:fake_payment_process) do
            keep_tidy do
              FlexCommerce::PaymentProcess.create cart_id: global_cart.id,
                payment_gateway_reference: "paypal_express_test",
                payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id }
            end
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
            keep_tidy do
              FlexCommerce::PaymentProcess.create  cart_id: global_cart.id,
                payment_gateway_reference: "paypal_express_test",
                payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id },
                post_processes: ["middleware_1", "middleware_2"]
            end
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
            keep_tidy do
              FlexCommerce::PaymentProcess.create cart_id: global_cart.id,
                payment_gateway_reference: "paypal_express_test",
                payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id },
                additional_processes: ["middleware_1", "middleware_2"]
            end
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
            keep_tidy do
              FlexCommerce::PaymentProcess.create cart_id: global_cart.id,
                payment_gateway_reference: "paypal_express_test",
                payment_gateway_response: { "token" => fake_token, "payer_id" => fake_payer_id }
            end
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
  end
end
