module Organizer
  module Group
    class Item < Array
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::Item, Organizer::Source::Item

      attr_reader :grouping_criteria
      attr_reader :group_name
      attr_reader :parent_name

      # @param _name [Symbol] symbol to identify this particular group.
      # @param _grouping_criteria attribute the items will be grouped. If nil, _name will be used insted.
      # @param _parent_name stores the group parent name of this instance if has one.
      def initialize(_name, _grouping_criteria = nil, _parent_name = nil)
        _grouping_criteria = _name if _grouping_criteria.blank?
        @item_name = _name
        @group_name = _name
        @grouping_criteria = _grouping_criteria
        @parent_name = _parent_name
      end

      def particularize_group(_group_value)
        @item_name = _group_value.to_s
      end

      # Checks if instace has parent name.
      #
      # @return [Boolean]
      def has_parent?
        !!self.parent_name
      end
    end
  end
end
