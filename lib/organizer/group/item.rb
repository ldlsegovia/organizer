module Organizer
  module Group
    class Item < Array
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::Item, Organizer::Source::Item

      attr_reader :group_name, :group_by_attr, :parent_name

      def initialize(_name, _group_by_attr = nil, _parent_name = nil)
        @item_name = _name
        @group_name = _name
        @group_by_attr = _group_by_attr || _name
        @parent_name = _parent_name
      end

      def particularize_group(_group_value)
        @item_name = _group_value.to_s
      end

      def has_parent?
        !!parent_name
      end

      def apply(_item)
        _item.send(group_by_attr)
      end
    end
  end
end
