module FlexCommerceApi
  module Error
    class BadRequest < ClientError
      def message
        msg = response_env[:body]["errors"].map { |e| "#{e["title"]} - #{e["detail"]}" }.join(" , ")
        "Bad Request #{msg}"
      end
    end
  end
end
