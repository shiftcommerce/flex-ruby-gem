require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Static Page model
  #
  # This model provides access to the flex commerce static pages.
  # As managing the static pages is the job of the administration panel, this
  # model is read only.
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Fetching all static pages
  #
  #   FlexCommerce::StaticPage.all #fetches all static pages (actually the first page in case there are thousands)
  #
  #   # Pagination
  #
  #   FlexCommerce::StaticPage.paginate(page:2).all # Fetches page 2 of static pages.
  #   The page size is predefined on the server side
  #
  #   # Finding static pages
  #
  #   FlexCommerce::StaticPage.find(25) # Finds the static page with this unique id
  #
  #
  class StaticPage < FlexCommerceApi::ApiBase
    # @method find
    # @param [String] spec
    # Finds a static page
    # @return [FlexCommerce::Product] The static page
    # @raise [FlexCommerceApi::Error::NotFound] If not found

    # @method all
    # Returns all static pages
    # @return [FlexCommerce::StaticPage[]] An array of static pages or an empty array

    # @method paginate
    # Paginates the list of static pages by a preset page size
    # @param [Hash] options The options to paginate with
    # @param options [Numeric|String] :page The page to fetch

    # @TODO Document other popular methods that we will support

  end
end
