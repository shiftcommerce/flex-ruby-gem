require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Product model
  #
  # This model provides access to the flex commerce products.
  # As managing the products is the job of the administration panel, this
  # model is read only.
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Fetching all products
  #
  #   FlexCommerce::Product.all #fetches all products(actually the first page in case there are thousands)
  #
  #   # Pagination
  #
  #   FlexCommerce::Product.paginate(page:2).all # Fetches page 2 of products.
  #   The page size is predefined on the server side
  #
  #   # Finding products
  #
  #   FlexCommerce::Product.find("my-product-slug") # Finds the product with this unique id
  #
  #   # Finding nested variants of the product
  #
  #   FlexCommerce::Product.find("my-product-slug").variants
  #
  #
  class Product < FlexCommerceApi::ApiBase
    # @method find
    # @param [String] spec
    # Finds a product
    # @return [FlexCommerce::Product] product The product
    # @raise [FlexCommerceApi::Error::NotFound] If not found

    # @method all
    # Returns all products
    # @return [FlexCommerce::Product[]] An array of products or an empty array

    # @method paginate
    # Paginates the list of products by a preset page size
    # @param [Hash] options The options to paginate with
    # @param options [Numeric|String] :page The page to fetch

    # @method variants
    # Provides a list of associated variants
    # @return [FlexCommerce::Variant[]]

    # @TODO Document other popular methods that we will support

    has_many :variants, class_name: "::FlexCommerce::Variant"
    has_many :breadcrumbs, class_name: "::FlexCommerce::Breadcrumb"
    has_many :asset_files, class_name: "::FlexCommerce::AssetFile"
    has_many :bundle_group, class_name: "::FlexCommerce::BundleGroup"

    # Here we override breadcrumbs to provide a proxy to the array so we can use find on it in the normal
    # active record way
    def breadcrumbs
      has_many_association_proxy :breadcrumbs, super
    end

    # TODO Decide where sku really comes from - its in the variant but not at product level like in matalan direct appears to be
    def sku
      reference
    end
    self.query_builder = ::FlexCommerceApi::JsonApiClientExtension::Builder
    class << self
      def_delegators :_new_scope, :temp_search
      def path(params, *args)
        if params[:filter] && params[:filter].key?(:category_id) && params[:filter].key?(:category_tree_id)
          category_tree_id = params[:filter].delete(:category_tree_id)
          category_id = params[:filter].delete(:category_id)
          params.delete(:filter) if params[:filter].empty?
          "category_trees/#{category_tree_id}/categories/#{category_id}/products"
        else
          super
        end
      end
    end
  end
end
