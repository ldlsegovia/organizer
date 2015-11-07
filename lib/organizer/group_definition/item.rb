module Organizer
  module GroupDefinition
    class Item < Array
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Explainer

      def initialize(_group_name)
        @item_name = _group_name
      end

      def add_memo_operation(_operation_name, _initial_value = 0, &block)
        memo_operations.add_memo_operation(_operation_name, _initial_value, &block)
      end

      def memo_operations
        @memo_operations ||= Organizer::Operation::Collection.new
      end
    end
  end
end
