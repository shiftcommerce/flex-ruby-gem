require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce SearchSuggestion model
  #
  # This model provides access to the Shift Suggestive Search feature.
  #
  # It is used much like an active record model.
  #
  # Examples:
  #
  #   # Fetch words matching the suggestion 'sh'
  #   FlexCommerce::SearchSuggestion.where(q: “sh”).all
  #
  class SearchSuggestion < FlexCommerceApi::ApiBase
  end
end
