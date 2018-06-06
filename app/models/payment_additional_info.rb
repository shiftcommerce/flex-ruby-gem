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
    attr_accessor :meta, :id

    def self.find(values)
      apply_gateway_response_filter(records, values).first
    end

    def self.records(*)
      []
    end

    def self.apply_sort(records, *)
      records
    end

    def self.apply_pagination(records, *)
      records
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

    def self.apply_gateway_response_filter(records, values)
      records << ::FlexCommerce::Payments::AdditionalInfo.new(payment_provider_id: values[:gateway_response][:payment_provider_id], options: values[:gateway_response].except(:payment_provider_id)).call
    end
  end
end
