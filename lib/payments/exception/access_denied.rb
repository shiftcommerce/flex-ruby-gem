require_relative 'transaction'

module FlexCommerce
  module Payments
    module Exception
      class AccessDenied < Transaction
      end
    end
  end
end
