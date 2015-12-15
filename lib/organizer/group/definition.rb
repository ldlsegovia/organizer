module Organizer
  module Group
    class Definition < Array
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_reader :group_by_attr
      attr_accessor :parent_item_operations, :item_operations
      attr_accessor :sort_items, :filters

      def initialize(_group_name, _group_by_attr = nil)
        @item_name = _group_name
        @group_by_attr = _group_by_attr || _group_name

        @parent_item_operations = Organizer::Operation::Collection.new
        @item_operations = Organizer::Operation::Collection.new
        @sort_items = Organizer::Sort::Collection.new
        @filters = Organizer::Filter::Collection.new
      end

      def add_children_based_operation(_operation, _initial_value = 0, &block)
        if _operation.is_a?(Organizer::Group::Operation::ParentItem)
          parent_item_operations << _operation
        else
          parent_item_operations.add_group_parent_item(_operation, _initial_value, &block)
        end

        parent_item_operations.last
      end
    end
  end
end
