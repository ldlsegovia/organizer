module Organizer
  module Group
    class Definition < Array
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_reader :group_by_attr
      attr_accessor :memo_operations, :sort_items, :filters

      def initialize(_group_name, _group_by_attr = nil)
        @item_name = _group_name
        @group_by_attr = _group_by_attr || _group_name

        @memo_operations = Organizer::Operation::Collection.new
        @sort_items = Organizer::Sort::Collection.new
        @filters = Organizer::Filter::Collection.new
      end

      def add_memo_operation(_operation, _initial_value = 0, &block)
        if _operation.is_a?(Organizer::Operation::Memo)
          memo_operations << _operation
        else
          memo_operations.add_memo_operation(_operation, _initial_value, &block)
        end

        memo_operations.last
      end
    end
  end
end