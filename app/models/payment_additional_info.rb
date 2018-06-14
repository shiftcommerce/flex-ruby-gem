module FlexCommerce
  #
  # A flex commerce PaymentAdditionalInfo model
  #
  # This will be triggered once user returns back to paypal confirmation page.
  # This model will get address details and shipping method back from paypal.
  #
  class PaymentAdditionalInfo
    include ActiveModel::Model
    attr_accessor :meta, :id, :payment_provider_id, :options

    # @method call
    # 
    # Triggers call to Paypal Express and fetch the info about the 
    # billing, shipping address and shipping method details
    # 
    # @return [FlexCommerce::PaymentAdditionalInfo]
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

    private

    def apply_gateway_response_filter
      # Call AdditionalInfo service class to trigger Paypal for details
      records << ::FlexCommerce::Payments::PaypalExpress::AdditionalInfo.new(
                    payment_provider: payment_provider,
                    options: options).call
    end

    def payment_provider
      FlexCommerce::PaymentProvider.all.select{ |p| p.reference == payment_provider_id }.first
    end

  end
end
