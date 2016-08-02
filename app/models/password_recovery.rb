require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Password Recovery model
  #
  # This model provides access to the flex commerce customer account password recovery functionality.
  # It is used much like an active record model.

  class PasswordRecovery < FlexCommerceApi::ApiBase
    belongs_to :customer_account, class_name: "::FlexCommerce::CustomerAccount"

    def self.path(params, *args)
      # Since it is singletone resource, use singular name in path and remove id
      params.delete(:id) if params.key?(:id)
      path = super.gsub(table_name, resource_name)
      params.delete(:customer_account_id) if params.key?(:customer_account_id)
      path
    end
  end
end
