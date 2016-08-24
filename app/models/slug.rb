require "flex_commerce_api/api_base"

module FlexCommerce
  #
  # A flex commerce Slug model
  #
  # This model provides access to flex commerce slugs
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #   # Fetching a slug
  #   FlexCommerce::Slug.find(computed_slug:'some-computed-slug')
  #
  class Slug < FlexCommerceApi::ApiBase
    has_one :resource
  end
end
