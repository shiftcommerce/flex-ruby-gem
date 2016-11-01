require 'json_api_client/included_data'

module FlexCommerceApi
  module JsonApiClientExtension
    class IncludedData < ::JsonApiClient::IncludedData
      def initialize(result_set, *args)
        super(result_set, *args)
        @result_set = result_set
      end

      private

      # attempt to load the record from included data first, failing that, look
      # in the root resource(s) for the record
      def record_for(link_def)
        data.dig(link_def["type"], link_def["id"]) || root_record_for(link_def)
      end

      def root_record_for(link_def)
        @result_set.find do |resource|
          resource.attributes["type"] == link_def["type"] &&
          resource.attributes["id"] == link_def["id"]
        end
      end
    end
  end
end