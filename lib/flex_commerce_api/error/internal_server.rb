module FlexCommerceApi
  module Error
    class InternalServer < Base
      def message
        body = response_env.fetch(:body, {errors: []})
        error = body[:errors].first
        if error
          title = error.fetch(:title, "")
          detail = error.fetch(:detail, "")
          backtrace = error.fetch(:meta, {backtrace: []}).fetch(:backtrace)
          "Internal server error - #{title} #{detail} #{backtrace}"
        else
          "Internal server error"
        end
      end

    end
  end
end