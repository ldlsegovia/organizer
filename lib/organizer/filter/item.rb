module Organizer
  module Filter
    class Item
      include Organizer::Error
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_reader :definition, :accept_value

      def initialize(_definition, _name = nil)
        raise_error(:definition_must_be_a_proc) if !_definition.is_a?(Proc)
        @definition = _definition
        @item_name = _name
      end

      def apply(_item, _value = nil)
        raise_error(:apply_on_organizer_items_only) if !_item.is_a?(Organizer::Source::Item)

        result = if definition.parameters.count == 2
                   definition.call(_item, _value)
                 else
                   definition.call(_item)
                 end

        raise_error(:definition_must_return_boolean) if !!result != result
        result
      end
    end
  end
end
