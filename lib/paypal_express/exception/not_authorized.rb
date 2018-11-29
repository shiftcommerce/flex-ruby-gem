require_relative 'transaction'

module FlexCommerce
  module PaypalExpress
    module Exception
      class NotAuthorized < Transaction
      end
    end
  end
end
