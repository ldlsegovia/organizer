module Organizer
  module Filter
    class Item
      include Organizer::Error
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_reader :definition

      def initialize(_definition, _name = nil)
        raise_error(:definition_must_be_a_proc) if !_definition.is_a?(Proc)
        @definition = _definition
        @item_name = _name
      end

      def apply(_item, _value = nil)
        raise_error(:apply_on_collection_items_only) if !_item.is_a?(Organizer::CollectionItem)
        result = definition.parameters.count == 2 ? definition.call(_item, _value) : definition.call(_item)
        raise_error(:definition_must_return_boolean) if !!result != result
        result
      end
    end
  end
end
