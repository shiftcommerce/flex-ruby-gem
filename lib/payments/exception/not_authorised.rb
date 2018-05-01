require_relative 'transaction'
module FlexCommerce
  module Payments
    module Exception
      class NotAuthorised < Transaction
      end
    end
  end
end
