require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Breadcrumb model
  #
  # This model provides access to the flex commerce breadcrumbs.
  # This model is read only.
  #
  # It is used much like an active record model.
  #
  class Breadcrumb < FlexCommerceApi::ApiBase
    has_many :breadcrumb_items
  end
end