module FlexCommerceApi
  module JsonApiClientExtension
    # @!visibility private
    # This class overrides the default paginator to allow for
    # the custom things that are required by the flex platform.
    # This class is private and should not be used by end users
    class Paginator < ::JsonApiClient::Paginating::Paginator
      def current_page
        params.fetch("page[number]", 1).to_i
      end

      def total_pages
        result_set.meta.page_count
      end

      def total_entries
        result_set.meta.total_entries
      end

      protected
    end
  end
end
