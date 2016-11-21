require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce template definition model
  #
  # This model provides access to the flex commerce template definition
  #
  #
  class TemplateDefinition < FlexCommerceApi::ApiBase
    has_many :template_sections, class_name: "::FlexCommerce::TemplateSection"
  end
end
