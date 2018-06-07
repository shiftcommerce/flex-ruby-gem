module FlexCommerce
  #
  # A flex commerce payment additional info model
  #
  # This will be triggered once user returns back to paypal confirmation page.
  # This model will get address details and shipping method back from paypal.
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
      records << ::FlexCommerce::Payments::PaypalExpress::AdditionalInfo.new(
                    payment_provider: payment_provider,
                    options: options).call
    end

    def payment_provider
      FlexCommerce::PaymentProvider.all.select{ |p| p.reference == payment_provider_id }.first
    end

  end
end
