module Organizer
  module Group
    class Item < Array
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::Item, Organizer::Source::Item

      attr_reader :group_name
      attr_reader :parent_name
      attr_reader :group_by_attr
      attr_reader :grouping_condition
      attr_reader :grouping_criteria

      def initialize(_name, _grouping_criteria = nil, _parent_name = nil)
        set_grouping_criteria(_name, _grouping_criteria)
        set_group_name(_name)
        @parent_name = _parent_name
      end

      def particularize_group(_group_value)
        @item_name = _group_value.to_s
      end

      def has_parent?
        !!parent_name
      end

      def apply_grouping_criteria(_item)
        return _item.send(group_by_attr) if group_by_attr
        return grouping_condition.call(_item) if grouping_condition
        raise_error(:undefined_criteria)
      end

      private

      def set_grouping_criteria(_name, _criteria)
        if !_criteria
          @group_by_attr = _name

        elsif _criteria.is_a?(Symbol)
          @group_by_attr = _criteria

        elsif _criteria.is_a?(String)
          @grouping_condition = Proc.new { |item| eval(_criteria) }
        end

        @grouping_criteria = group_by_attr || _criteria
      end

      def set_group_name(_name)
        _name = group_by_attr if !_name && !!group_by_attr
        raise_error(:group_name_is_mandatory) unless _name
        @item_name = _name
        @group_name = _name
      end
    end
  end
end
