require "digest"
module FlexCommerce
  module Payments
    module TransactionHash
      def self.call(t)
        Digest::SHA2.hexdigest("#{t.gateway_response.to_json}::#{t.container_id}::#{t.payment_gateway_reference}::#{t.transaction_type}::#{t.status}")
      end
    end
  end
end
