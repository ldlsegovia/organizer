module Organizer
  module Group
    class Definition < Array
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_reader :group_by_attr
      attr_accessor :children_based_operations, :group_item_operations
      attr_accessor :sort_items, :filters

      def initialize(_group_name, _group_by_attr = nil)
        @item_name = _group_name
        @group_by_attr = _group_by_attr || _group_name

        @children_based_operations = Organizer::Operation::Collection.new
        @sort_items = Organizer::Sort::Collection.new
        @filters = Organizer::Filter::Collection.new
      end

      def add_children_based_operation(_operation, _initial_value = 0, &block)
        if _operation.is_a?(Organizer::Operation::Memo)
          children_based_operations << _operation
        else
          children_based_operations.add_memo_operation(_operation, _initial_value, &block)
        end

        children_based_operations.last
      end
    end
  end
end
