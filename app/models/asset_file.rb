require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce asset file model
  #
  # This model provides access to the flex asset file
  #
  # It is used much like an active record model.
  #
  class AssetFile < FlexCommerceApi::ApiBase
    belongs_to :asset_folder
    def self.path(params, resource)
      if !params.key?("asset_folder_id") && !params.key?("path") && resource
        resource.relationships["asset_folder"]["links"]["related"].gsub(/\.json_api$/, '') + "/asset_files"
      else
        super
      end
    end
  end
end
