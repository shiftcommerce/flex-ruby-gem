module FlexCommerceApi
  module Error
    class Base < StandardError
      attr_reader :env
      def initialize(env)
        @env = env
      end

    end
  end
end