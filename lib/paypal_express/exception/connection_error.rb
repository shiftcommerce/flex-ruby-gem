require_relative 'transaction'

module FlexCommerce
  module PaypalExpress
    module Exception
      class ConnectionError < Transaction
      end
    end
  end
end
