module Organizer
  module Group
    class Definition < Array
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_reader :group_by_attr
      attr_accessor :parent_item_operations, :item_operations, :child_item_operations
      attr_accessor :sort_items, :filters, :limit_item

      def initialize(_group_name, _group_by_attr = nil)
        @item_name = _group_name
        @group_by_attr = _group_by_attr || _group_name

        @parent_item_operations = Organizer::Operation::Collection.new
        @child_item_operations = Organizer::Operation::Collection.new
        @item_operations = Organizer::Operation::Collection.new
        @sort_items = Organizer::Sort::Collection.new
        @filters = Organizer::Filter::Collection.new
      end
    end
  end
end
