module FlexCommerceApi
  module Error
    class InternalServer < Base
      def message
        body = response_env.fetch(:body, {"errors" => []})
        error = extract_error(body)
        return "Internal server error" unless error.present?
        if error.is_a?(::Enumerable)
          title = error.fetch("title", "")
          detail = error.fetch("detail", "")
          meta = error.fetch("meta", {})
          exception = meta.fetch("exception", "")
          backtrace = meta.fetch("backtrace", [])
          event_id = meta.fetch("event_id", "")
          "Internal server error - #{title} #{detail} #{event_id} #{exception} #{backtrace}"
        else
          "Internal server error - #{error}"
        end
      end

      private

      def extract_error(body)
        return body if body.is_a?(::String)
        body["message"] || body["errors"]&.first
      end
    end
  end
end
