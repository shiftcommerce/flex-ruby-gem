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

    # @TODO Document other popular methods that we will support
  end
end
