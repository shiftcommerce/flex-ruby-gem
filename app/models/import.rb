require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Category tree model
  #
  # This model provides access to the flex commerce category tree and associated categories.
  class Import < FlexCommerceApi::ApiBase
    has_many :import_entries, class_name: "FlexCommerce::ImportEntry"
  end
end
