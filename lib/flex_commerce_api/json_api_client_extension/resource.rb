require "json_api_client/resource"
require_relative "./parsers/parser"
module FlexCommerceApi
  module JsonApiClientExtension
    class Resource < JsonApiClient::Resource
      self.parser = Parsers::Parser
      def method_missing(method, *args)
        association = association_for(method)

        return super unless association || (relationships && relationships.has_attribute?(method))

        return nil unless relationship_definitions = relationships[method]

        # look in included data
        if relationship_definitions.key?("data")
          return last_result_set.included.data_for(method, relationship_definitions) || last_result_set.find do |resource|
            data = relationship_definitions["data"]
            if data.is_a?(Array)
              data.map do |link_def|
                find_record_for(link_def)
              end
            elsif data.nil?
              nil
            else
              find_record_for(data)
            end
          end
        end

        if association = association_for(method)
          # look for a defined relationship url
          if relationship_definitions["links"] && url = relationship_definitions["links"]["related"]
            return association.data(url)
          end
        end
        nil
      end

      def find_record_for(link_def)
        last_result_set.find {|resource| resource.attributes["id"] == link_def["id"] && resource.attributes["type"] == link_def["type"]}
      end
    end
  end
end