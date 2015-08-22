module Organizer
  module Group
    class Item < Array
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::Item, Organizer::Source::Item

      attr_reader :group_by_attr
      attr_reader :group_name
      attr_reader :parent_name

      # @param _name [Symbol] symbol to identify this particular group.
      # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
      # @param _parent_name stores the group parent name of this instance if has one.
      def initialize(_name, _group_by_attr = nil, _parent_name = nil)
        _group_by_attr = _name if _group_by_attr.blank?
        @item_name = _name
        @group_name = _name
        @group_by_attr = _group_by_attr
        @parent_name = _parent_name
      end

      def particularize_group(_group_value)
        @item_name = _group_value.to_s
      end
    end
  end
end
