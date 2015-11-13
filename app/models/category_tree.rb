require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Category tree model
  #
  # This model provides access to the flex commerce category tree and associated categories.
  class CategoryTree < FlexCommerceApi::ApiBase
    has_many :categories, class_name: "::FlexCommerce::Category"
  end
end
