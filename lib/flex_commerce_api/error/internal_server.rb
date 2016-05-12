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
          exception = error.fetch("meta", {"exception" => ""}).fetch("exception")
          backtrace = error.fetch("meta", {"backtrace" => []}).fetch("backtrace")
          "Internal server error - #{title} #{detail} #{exception} #{backtrace}"
        else
          "Internal server error - #{error}"
        end
      end

    end
  end
end