module FlexCommerceApi
  module JsonApiClientExtension
    class Requestor < ::JsonApiClient::Query::Requestor
      # expects a record
      def create(record)
        request(:post, klass.path(record.attributes, record), {
                         data: record.as_json_api
                     })
      end

      def update(record)
        request(:patch, resource_path(record.attributes, record), {
                          data: record.as_json_api
                      })
      end

      def get(params = {})
        path = resource_path(params)
        params.delete(klass.primary_key)
        request(:get, path, params)
      end

      def destroy(record)
        request(:delete, resource_path(record.attributes, record), {})
      end

      protected

      def resource_path(parameters, record = nil)
        if resource_id = parameters[klass.primary_key]
          File.join(klass.path(parameters, record), encoded(resource_id))
        else
          klass.path(parameters, record)
        end
      end

      def encoded(part)
        Addressable::URI.encode_component(part, Addressable::URI::CharacterClasses::UNRESERVED + "\\:")
      end


    end
  end
end