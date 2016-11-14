require "flex_commerce_api/api_base"
module FlexCommerce
  #
  # A flex commerce template
  #
  class Template < FlexCommerceApi::ApiBase
    has_many :sections, class_name: "::FlexCommerce::Section"

    def method_missing(method, *args)
      if relationships and relationships.has_attribute?(method)
        super
      elsif has_attribute?(method) || method.to_s=~(/=$/) || method.to_s=~/!$/
        super
      elsif sections.map { |s| s.reference.to_sym }.include?(method)
        sections.select { |s| s.reference.to_sym == method }.first
      else
        nil
      end
    end
  end
end
