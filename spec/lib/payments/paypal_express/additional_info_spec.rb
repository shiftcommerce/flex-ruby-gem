require "e2e_spec_helper"


RSpec.describe FlexCommerce::Payments::PaypalExpress::AdditionalInfo, vcr: true, paypal: true do
  include ActiveSupport::NumberHelper
  include_context "context store"
  include_context "housekeeping"
  
  # Mock active merchant
  let!(:active_merchant_gateway_class) { class_double("ActiveMerchant::Billing::PaypalExpressGateway", new: active_merchant_gateway).as_stubbed_const }
  let!(:active_merchant_gateway) { instance_double("ActiveMerchant::Billing::PaypalExpressGateway") }

  # Mock the payment provider
  let!(:payment_provider_class) { class_double("PaymentProvider").as_stubbed_const }
  let(:payment_provider) { instance_double("PaymentProvider", test_mode: true, reference: "paypal_express_test", service: "paypal_express", meta_attributes: { "login" => "login", "password" => "password", "signature" => "signature" }) }
  let(:valid_token) { "valid_token" }
  subject { described_class.new(payment_provider: payment_provider, options: { token: valid_token }) }

  # As we are not testing the paypal service itself, we are only interested in what happens
  # when specific canned paypal responses are returned from the mocks, then the inputs to
  # all examples are the same - see below

  context "#call" do
    context "with valid token" do
      let!(:shipping_method) do
        FlexCommerce::ShippingMethod.first
      end
      before(:each) do
        expect(active_merchant_gateway).to receive(:details_for).with(valid_token).and_return details_for_response
      end
      let(:shipping_option_name) { shipping_method.label }
      let(:details_for_response) do
        instance_double "ActiveMerchant::Billing::PaypalExpressResponse", "get_express_checkout_details", success?: true, params: {
          "timestamp"=>"2016-04-11T12:59:43Z",
          "ack"=>"Success",
          "correlation_id"=>"8ebedb786508d",
          "version"=>"124",
          "build"=>"000000",
          "token"=>"EC-3RS20801E7866424N",
          "payer"=>"ryan+paypal-buyer@flexcommerce.com",
          "payer_id"=>"fake-payer-id",
          "payer_status"=>"verified",
          "salutation"=>nil,
          "first_name"=>"test",
          "middle_name"=>nil,
          "last_name"=>"buyer",
          "suffix"=>nil,
          "payer_country"=>"GB",
          "payer_business"=>nil,
          "name"=>"Variant 2 for Product 25 - Gorgeous Wool Hat",
          "street1"=>"Jaden Prairie",
          "street2"=>"224 Ollie Light",
          "city_name"=>"Kubchester",
          "state_or_province"=>"Indiana",
          "country"=>"San Marino",
          "country_name"=>"United Kingdom",
          "postal_code"=>"21322",
          "address_owner"=>"PayPal",
          "address_status"=>"Confirmed",
          "billing_agreement_accepted_status"=>"false",
          "order_total"=>"426.66",
          "order_total_currency_id"=>"GBP",
          "item_total"=>"426.66",
          "item_total_currency_id"=>"GBP",
          "shipping_total"=>"0.00",
          "shipping_total_currency_id"=>"GBP",
          "handling_total"=>"0.00",
          "handling_total_currency_id"=>"GBP",
          "tax_total"=>"0.00",
          "tax_total_currency_id"=>"GBP",
          "order_description"=>"THE DEFAULT DESCRIPTION - TO BE CHANGED",
          "phone"=>nil,
          "address_id"=>nil,
          "external_address_id"=>nil,
          "address_normalization_status"=>"None\n            ",
          "number"=>"Number",
          "quantity"=>"1",
          "tax"=>"0.00",
          "tax_currency_id"=>"GBP",
          "amount"=>"61.78",
          "amount_currency_id"=>"GBP",
          "ebay_item_payment_details_item"=>nil,
          "description"=>"Variant 2 for Product 25 - Gorgeous Wool Hat",
          "insurance_total"=>"0.00",
          "insurance_total_currency_id"=>"GBP",
          "shipping_discount"=>"0.00",
          "shipping_discount_currency_id"=>"GBP",
          "insurance_option_offered"=>"false",
          "seller_details"=>nil,
          "payment_request_id"=>nil,
          "order_url"=>nil,
          "soft_descriptor"=>nil,
          "shipping_calculation_mode"=>"FlatRate",
          "insurance_option_selected"=>"false",
          "shipping_option_is_default"=>"true",
          "shipping_option_amount"=>number_to_rounded(shipping_method.total, precision: 2),
          "shipping_option_amount_currency_id"=>"GBP",
          "shipping_option_name"=>shipping_option_name,
          "checkout_status"=>"PaymentActionNotInitiated",
          "payment_request_info"=>nil,
          "transaction_id"=>nil,
          "parent_transaction_id"=>nil,
          "receipt_id"=>nil,
          "transaction_type"=>"none",
          "payment_type"=>"none",
          "exchange_rate"=>nil,
          "payment_status"=>"None",
          "pending_reason"=>"none",
          "reason_code"=>"none",
          "Token"=>"EC-3RS20801E7866424N",
          "PayerInfo"=>{
            "Payer"=>"ryan+paypal-buyer@flexcommerce.com",
            "PayerID"=>"fake-payer-id",
            "PayerStatus"=>"verified",
            "PayerName"=>{
              "Salutation"=>nil,
              "FirstName"=>"test",
              "MiddleName"=>nil,
              "LastName"=>"buyer",
              "Suffix"=>nil
            },
            "PayerCountry"=>"GB",
            "PayerBusiness"=>nil,
            "Address"=>{
              "Name"=>"Dariana3suffix Rosanna3suffix Blick3suffix",
              "Street1"=>"Evelyn Parkway",
              "Street2"=>"717 Amya Stravenue",
              "CityName"=>"New Haylie",
              "StateOrProvince"=>"Illinois",
              "Country"=>"Kiribati",
              "CountryName"=>"United Kingdom",
              "PostalCode"=>"11669",
              "AddressOwner"=>"PayPal",
              "AddressStatus"=>"Confirmed"
            }
          },
          "BillingAgreementAcceptedStatus"=>"false",
          "PaymentDetails"=>{
            "OrderTotal"=>"426.66",
            "ItemTotal"=>"426.66",
            "ShippingTotal"=>"0.00",
            "HandlingTotal"=>"0.00",
            "TaxTotal"=>"0.00",
            "OrderDescription"=>"THE DEFAULT DESCRIPTION - TO BE CHANGED",
            "ShipToAddress"=>{
              "Name"=>"Dale4suffix Germaine4suffix Grady4suffix",
              "Street1"=>"Jaden Prairie",
              "Street2"=>"224 Ollie Light",
              "CityName"=>"Kubchester",
              "StateOrProvince"=>"Indiana",
              "Country"=>"San Marino",
              "CountryName"=>"United Kingdom",
              "Phone"=>nil,
              "PostalCode"=>"21322",
              "AddressID"=>nil,
              "AddressOwner"=>"PayPal",
              "ExternalAddressID"=>nil,
              "AddressStatus"=>"Confirmed",
              "AddressNormalizationStatus"=>"None\n            "
            },
            "PaymentDetailsItem"=>{
              "Name"=>"Variant 2 for Product 25 - Gorgeous Wool Hat",
              "Number"=>"Number",
              "Quantity"=>"1",
              "Tax"=>"0.00",
              "Amount"=>"61.78",
              "EbayItemPaymentDetailsItem"=>nil,
              "Description"=>"Variant 2 for Product 25 - Gorgeous Wool Hat"
            },
            "InsuranceTotal"=>"0.00",
            "ShippingDiscount"=>"0.00",
            "InsuranceOptionOffered"=>"false",
            "SellerDetails"=>nil,
            "PaymentRequestID"=>nil,
            "OrderURL"=>nil,
            "SoftDescriptor"=>nil
          },
          "UserSelectedOptions"=>{
            "ShippingCalculationMode"=>"FlatRate",
            "InsuranceOptionSelected"=>"false",
            "ShippingOptionIsDefault"=>"true",
            "ShippingOptionAmount"=>number_to_rounded(shipping_method.total, precision: 2),
            "ShippingOptionName"=>shipping_method.label
          },
          "CheckoutStatus"=>"PaymentActionNotInitiated",
          "PaymentRequestInfo"=>nil,
          "PaymentInfo"=>{
            "TransactionID"=>nil,
            "ParentTransactionID"=>nil,
            "ReceiptID"=>nil,
            "TransactionType"=>"none",
            "PaymentType"=>"none",
            "ExchangeRate"=>nil,
            "PaymentStatus"=>"None",
            "PendingReason"=>"none",
            "ReasonCode"=>"none",
            "SellerDetails"=>nil
          }

        }
      end

      it "should return an additional info model" do
        expect(subject.call).to be_a(FlexCommerce::PaymentAdditionalInfo)
      end

      it "should reference the correct shipping method" do
        expect(subject.call).to have_attributes meta: a_hash_including(shipping_method_id: shipping_method.id)
      end

      context "when paypal is misbehaving with duplicate shipping option names" do
        let(:shipping_option_name) { "#{shipping_method.label} #{shipping_method.label}"  }

        it "should reference the correct shipping method" do
          expect(subject.call).to have_attributes meta: a_hash_including(shipping_method_id: shipping_method.id)
        end
      end

      it "should have the correct shipping address attributes" do
        expected_address_attributes = {
          "first_name"=>"Dale4suffix",
          "last_name"=>"Grady4suffix",
          "middle_names"=>"Germaine4suffix",
          "address_line_1"=>"Jaden Prairie",
          "address_line_2"=>"224 Ollie Light",
          "city"=>"Kubchester",
          "state"=>"Indiana",
          "country"=>"San Marino",
          "postcode"=>"21322"
        }
        expect(subject.call).to have_attributes meta: a_hash_including(shipping_address_attributes: expected_address_attributes)
      end

      it "should have the correct billing address attributes" do
        expected_address_attributes = {
          "first_name"=>"Dariana3suffix",
          "last_name"=>"Blick3suffix",
          "middle_names"=>"Rosanna3suffix",
          "address_line_1"=>"Evelyn Parkway",
          "address_line_2"=>"717 Amya Stravenue",
          "city"=>"New Haylie",
          "state"=>"Illinois",
          "country"=>"Kiribati",
          "postcode"=>"11669"
        }
        expect(subject.call).to have_attributes meta: a_hash_including(billing_address_attributes: expected_address_attributes)
      end
    end
    context "with invalid token response from paypal" do
      before(:each) do
        expect(active_merchant_gateway).to receive(:details_for).with(valid_token).and_return details_for_response
      end

      let(:details_for_response) do
        instance_double "ActiveMerchant::Billing::PaypalExpressResponse", "get_express_checkout_details", success?: false, message: "Invalid Token", params: {
            "GetExpressCheckoutDetailsResponse" => {
                "Ack" => "Failure",
                "Errors" => {
                  "ShortMessage" => "Invalid Token",
                  "LongMessage" => "Invalid Token.",
                  "ErrorCode" => "10410",
                  "SeverityCode" => "Error",

                  },
                "ConfirmationCode" => "Confirmed",
                "StreetMatch" => "Matched",
                "ZipMatch" => "Matched"
            }
        }
      end

      it "should return nil" do
        expect { subject.call }.to raise_error ::FlexCommerce::Payments::Exception::AccessDenied
      end
    end
  end
end