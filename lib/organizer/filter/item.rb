module Organizer
  module Filter
    class Item
      include Organizer::Error
      include Organizer::CollectionItem

      attr_reader :definition, :accept_value

      # @param _definition [Proc] contains logic to decide if filter must be applied or not.
      # @param _name [Symbol] symbol to identify this particular filter.
      # @param _accept_value sets true if you want to pass params to definition call.
      def initialize(_definition, _name = nil, _accept_value = false)
        raise_error(:definition_must_be_a_proc) if !_definition.is_a?(Proc)
        @definition = _definition
        @name = _name
        @accept_value = !!_accept_value
      end

      # Evaluates _item param against definition proc to know if item must be filtered or not.
      #
      # @param _item [Organizer::Source::Item]
      # @return [Boolean]
      #
      # @raise [Organizer::Filter::ItemException] :apply_on_organizer_items_only and
      #   :definition_must_return_boolean
      #
      # @example
      #   item = Organizer::Source::Item.new
      #   item.define_attributes({ attr1: 400, attr2: 266 })
      #
      #   proc = Proc.new do |organizer_item, value|
      #     (organizer_item.attr1 + organizer_item.attr2) == value
      #   end
      #
      #   Organizer::Filter::Item.new(proc, :my_filter, true).apply(item, 666)
      #   #=> true
      def apply(_item, _value = nil)
        raise_error(:apply_on_organizer_items_only) if !_item.is_a?(Organizer::Source::Item)
        result = !!accept_value ? definition.call(_item, _value) : definition.call(_item)
        raise_error(:definition_must_return_boolean) if !!result != result
        result
      end
    end
  end
end
