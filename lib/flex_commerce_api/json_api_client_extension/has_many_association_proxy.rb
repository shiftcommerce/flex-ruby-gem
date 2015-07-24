module FlexCommerceApi
  module JsonApiClientExtension
    class HasManyAssociationProxy
      def initialize(real_instance, container_instance, association_name)
        self.real_instance = real_instance
        self.container_instance = container_instance
        self.association_name = association_name
      end

      #
      # Finds an instance by primary key
      #
      # @param [Integer|Number|Float] pk The primary key value to be found
      # @return The resource found or nil if not found
      def find(pk)
        method = primary_key
        real_instance.detect {|i| i.send(method) == pk}
      end
      delegate :each, :each_with_index, :length, :count, to: :real_instance

      private

      def assocation
        container_instance.class.associations.detect {|a| a.attr_name == association_name.to_sym}
      end

      def primary_key
        assocation.association_class.primary_key
      end

      attr_accessor :real_instance, :container_instance, :association_name
    end
  end
end