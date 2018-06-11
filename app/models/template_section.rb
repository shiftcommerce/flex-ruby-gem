require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce template section model
  #
  # This model provides access to the flex commerce template section
  #
  #
  class TemplateSection < FlexCommerceApi::ApiBase
    has_one :template_definition, class_name: "::FlexCommerce::TemplateDefinition"
    has_many :template_components, class_name: "::FlexCommerce::TemplateComponent"
  end
end
