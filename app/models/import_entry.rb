require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Category tree model
  #
  # This model provides access to the flex commerce category tree and associated categories.
  class ImportEntry < FlexCommerceApi::ApiBase
    belongs_to :import, class_name: "FlexCommerce::Import"
  end
end
