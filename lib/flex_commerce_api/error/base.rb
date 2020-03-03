module FlexCommerceApi
  module Error
    class Base < StandardError
      attr_reader :response_env, :request_env
      def initialize(request_env = nil, response_env = nil)
        @response_env = response_env
        @request_env = request_env
      end
    end
  end
end
