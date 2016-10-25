module FlexCommerce
  module JsonApiClientExtension
    class IncludedData < ::JsonApiClient::IncludedData
      private

      # should return a resource record of some type for this linked document
      def record_for(link_def)
        return nil unless data.key?(link_def["type"])
        data[link_def["type"]][link_def["id"]]
      end
    end
  end
end