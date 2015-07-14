module Organizer
  module Operation
    class Item
      include Organizer::Error
      include Organizer::CollectionItem

      attr_accessor :error
      attr_reader :definition

      # @param _definition [Proc] contains logic to generate the value for this operation
      # @param _name [Symbol] symbol to identify this particular operation
      def initialize(_definition, _name)
        raise_error(:definition_must_be_a_proc) if !_definition.is_a?(Proc)
        raise_error(:blank_name) if !_name
        @definition = _definition
        @name = _name
      end

      def execute(_item)
        raise_error(:not_implemented)
      end

      # Checks if this operation has error
      #
      # @return [Boolean]
      def has_error?
        !error.blank? && !error.message.blank?
      end
    end
  end
end
