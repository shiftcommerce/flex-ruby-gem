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
      internal_params = params.with_indifferent_access
      if !internal_params.key?("asset_folder_id") && !internal_params.key?("path") && resource
        resource.relationships["asset_folder"]["links"]["related"].gsub(/\.json_api$/, '') + "/asset_files"
      elsif internal_params.key?("path") && internal_params["path"].key?("asset_folder_id") && internal_params["path"]["asset_folder_id"].is_a?(String)
        # As the asset_folder_id is going into the url, and the developer may sent it anything, then we should escape it
        new_params = internal_params.deep_dup
        new_params["path"]["asset_folder_id"] = URI.escape(new_params["path"]["asset_folder_id"])
        super(new_params, resource)
      else
        super
      end
    end
  end
end
