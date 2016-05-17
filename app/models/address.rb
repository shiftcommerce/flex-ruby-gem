require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Address model
  #
  # This model provides access to the flex commerce addresses
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Fetching all addresses for a customer account
  #
  #   customer_account.addresses.all #fetches all addresses(actually the first page in case there are thousands)
  #
  #
  class Address < FlexCommerceApi::ApiBase

    # @method all
    # Returns all addresses
    # @return [FlexCommerce::Address[]] An array of categories or an empty array
    class << self
      def path(params, instance = nil)
        if params[:filter] && params[:filter].key?(:customer_account_id)
          customer_account_id = params[:filter].delete(:customer_account_id)
          params.delete(:filter) if params[:filter].empty?
          "customer_accounts/#{customer_account_id}/addresses"
        elsif instance && instance.try(:customer_account_id) && instance.customer_account_id.present?
          "customer_accounts/#{instance.customer_account_id}/addresses"
        else
          super
        end
      end

    end

    has_one :customer_account
  end
end
