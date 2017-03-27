require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce payment additional info model
  #
  # The content depends on the payment gateway being used.  For paypal for example,
  # we will get address details and shipping method back from shift
  #
  #
  class PaymentAdditionalInfo < FlexCommerceApi::ApiBase

  end
end
