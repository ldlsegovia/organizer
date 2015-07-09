module Organizer
  module Operation
    class Item
      include Organizer::Error

      attr_accessor :error
      attr_reader :definition, :name

      # @param _definition [Proc] contains logic to generate the value for this operation
      # @param _name [Symbol] symbol to identify this particular operation
      def initialize(_definition, _name)
        raise_error(:definition_must_be_a_proc) if !_definition.is_a?(Proc)
        raise_error(:blank_name) if !_name
        @definition = _definition
        @name = _name
      end

      # Evaluates definition proc to build a new attribute. This attribute will be added to _item param.
      #
      # @param _item [Organizer::Source::Item] you can use item's attributes to build the new attribute
      # @return [Organizer::Source::Item] with the new attribute added
      #
      # @raise [Organizer::Operation::ItemException] :execute_over_organizer_items_only
      #
      # @example
      #   hash = { attr1: 400, attr2: 266 }
      #   item = Organizer::Source::Item.new
      #   item.define_attributes(hash)
      #
      #   proc = Proc.new do |organizer_item|
      #     organizer_item.attr1 + organizer_item.attr2
      #   end
      #
      #   item = Organizer::Operation::Item.new(proc, :attrs_sum).execute(item)
      #   item.attrs_sum
      #   #=> 666
      def execute(_item)
        raise_error(:execute_over_organizer_items_only) if !_item.is_a?(Organizer::Source::Item)
        result = definition.call(_item)
        _item.define_attribute(self.name, result)
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
