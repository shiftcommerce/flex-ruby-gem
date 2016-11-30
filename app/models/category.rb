require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce Category model
  #
  # This model provides access to the flex commerce categories and associated products.
  # As managing the categories is the job of the administration panel, this
  # model is read only.
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #
  #
  #   # Fetching all categories
  #
  #   FlexCommerce::Category.all #fetches all categories(actually the first page in case there are thousands)
  #
  #   # Pagination
  #
  #   FlexCommerce::Category.paginate(page:2).all # Fetches page 2 of categories.
  #   The page size is predefined on the server side
  #
  #   # Finding categories
  #
  #   FlexCommerce::Product.find("my-category-slug") # Finds the category with this unique id
  #
  #   # Finding nested categories of the category
  #
  #   FlexCommerce::Category.find("my-category-slug").categories
  #
  #   # Finding products within the categories
  #
  #   FlexCommerce::Category.find("my-category-slug").products
  #
  #   or if you already know the category id - then
  #
  #   @TODO Look into this
  #
  class Category < FlexCommerceApi::ApiBase
    # @method find
    # @param [String] spec
    # Finds a category
    # @return [FlexCommerce::Category] category The category
    # @raise [FlexCommerceApi::Error::NotFound] If not found

    # @method all
    # Returns all categories
    # @return [FlexCommerce::Category[]] An array of categories or an empty array

    # @method paginate
    # Paginates the list of categories by a preset page size
    # @param [Hash] options The options to paginate with
    # @param options [Numeric|String] :page The page to fetch

    # @method categories
    # Provides a list of associated sub categories
    # @return [FlexCommerce::Category[]]

    # @TODO Document other popular methods that we will support

    has_many :categories, class_name: "::FlexCommerce::Category"
    has_many :child_categories, class_name: "::FlexCommerce::Category"
    has_many :breadcrumbs, class_name: "::FlexCommerce::Breadcrumb"
    has_many :products, class_name: "::FlexCommerce::Product"
    has_many :slugs, class_name: "::FlexCommerce::Slug"
    belongs_to :category_tree, class_name: "::FlexCommerce::CategoryTree"
    has_one :template_definition, class_name: "::FlexCommerce::TemplateDefinition"
    has_one :template, class_name: "::FlexCommerce::Template"

    # Here we override breadcrumbs to provide a proxy to the array so we can use find on it in the normal
    # active record way
    def breadcrumbs
      has_many_association_proxy :breadcrumbs, super
    end
  end
end
