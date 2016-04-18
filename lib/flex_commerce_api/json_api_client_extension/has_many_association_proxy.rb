require "active_support/core_ext/module/delegation"

module FlexCommerceApi
  module JsonApiClientExtension
    class HasManyAssociationProxy
      def initialize(real_instance, container_instance, association_name, options)
        self.real_instance = real_instance
        self.container_instance = container_instance
        self.association_name = association_name
        self.options = options
      end

      delegate :empty?, :each, :each_with_index, :length, :count, :map, :select, :detect, :first, :last, :[], :any?, to: :real_instance
      #
      # Finds an instance by primary key
      #
      # @param [Integer|Number|Float] pk The primary key value to be found
      # @return The resource found or nil if not found
      def find(pk)
        method = primary_key
        real_instance.detect {|i| i.send(method) == pk}
      end

      # Creates a new associated item - if the option "inverse_of" is specified, then
      # automatically create a relationship back to the container with the name
      # specified in "inverse_of"
      def new(attrs)
        my_attrs = attrs.dup
        if options.key?(:inverse_of)
          my_attrs[:relationships] ||= {}
          # Dont modify the original relationship if it was present below
          my_attrs[:relationships] = my_attrs[:relationships].merge(options[:inverse_of] => container_instance)
        end
        association.association_class.new(my_attrs)
      end

      def create(attrs)
        new(attrs).tap do |instance|
          instance.save
        end
      end

      def to_a
        real_instance
      end

      private

      def association
        container_instance.class.associations.detect {|a| a.attr_name == association_name.to_sym}
      end

      def primary_key
        association.association_class.primary_key
      end

      attr_accessor :real_instance, :container_instance, :association_name, :options
    end
  end
end
