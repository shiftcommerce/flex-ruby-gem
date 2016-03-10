require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce asset folder model
  #
  # This model provides access to the flex asset folder and associated files
  #
  # It is used much like an active record model.
  #
  class AssetFolder < FlexCommerceApi::ApiBase
    has_many :asset_files
  end
end
