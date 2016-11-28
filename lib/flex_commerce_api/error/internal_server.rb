module FlexCommerceApi
  module Error
    class InternalServer < Base
      def message
        body = response_env.fetch(:body, {"errors" => []})
        error = body.is_a?(::String) ? body : body["errors"].first
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

    end
  end
end
