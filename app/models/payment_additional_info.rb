module FlexCommerce
  #
  # A flex commerce payment additional info model
  #
  # The content depends on the payment gateway being used.  For paypal for example,
  # we will get address details and shipping method back from shift
  #
  #
  class PaymentAdditionalInfo
    include ActiveModel::Model
    attr_accessor :meta, :id, :payment_provider_id, :options

    def call
      apply_gateway_response_filter.first
    end

    def records(*)
      []
    end

    def meta_attributes
      _model.meta.inject({}) do |acc, (key, value)|
        acc.merge key => { value: value, data_type: value.class.name.underscore }
      end
    end

    def meta_attribute(key)
      begin
        self.meta[key]
      rescue NoMethodError => e
        nil
      end
    end

    def apply_gateway_response_filter
      records << delegated_service_class.new(payment_provider: payment_provider, options: options).call
    end

    def delegated_service_class
      "::FlexCommerce::Payments::#{payment_provider_id.camelize}::AdditionalInfo".constantize
    end

    def payment_provider
      FlexCommerce::PaymentProvider.all.select{ |p| p.reference == payment_provider_id }.first
    end

  end
end
