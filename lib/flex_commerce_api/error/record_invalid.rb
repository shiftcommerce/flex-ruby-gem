module FlexCommerceApi
  module Error
    class RecordInvalid < Base
      attr_reader :record

      def initialize(record)
        @record = record
      end

      def message
        "Record Invalid - #{record.errors.full_messages.join(", ")}"
      end
    end
  end
end
