require_relative 'transaction'

module FlexCommerce
  module PaypalExpress
    module Exception
      class AccessDenied < Transaction
      end
    end
  end
end
