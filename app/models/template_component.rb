require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce template component model
  #
  # This model provides access to the flex commerce template component
  #
  #
  class TemplateComponent < FlexCommerceApi::ApiBase
    belongs_to template_section, class_name: "::FlexCommerce::TemplateSection"
  end
end
