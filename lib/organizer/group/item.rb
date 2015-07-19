module Organizer
  module Group
    class Item < Array
      include Organizer::Error
      include Organizer::CollectionItem
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::SubItem

      attr_reader :group_by_attr

      # @param _name [Symbol] symbol to identify this particular group.
      # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
      def initialize(_name, _group_by_attr = nil)
        _group_by_attr = _name if _group_by_attr.blank?
        @item_name = _name
        @group_by_attr = _group_by_attr
        @group_items = []
      end

      # Splits given collection into {Organizer::Group::SubItem}s based on group_by_attr
      #
      # @param _collection [Organizer::Source::Collection]
      # @return [Organizer::Group::Item] self
      def build(_collection)
        return self if _collection.size.zero?
        if !_collection.first.include_attribute?(self.group_by_attr)
          raise_error(:group_by_attr_not_present_in_collection)
        end

        group_items = _collection.group_by { |item| item.send(self.group_by_attr) }
        group_items.each do |attribute_value_items|
          items = attribute_value_items.last
          group_item = Organizer::Group::SubItem.new(items)
          self << group_item
        end

        self
      end
    end
  end
end
