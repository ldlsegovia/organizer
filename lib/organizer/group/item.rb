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

      # @param _name [Symbol] symbol to identify this particular group.
      # @param _grouping_criteria [String, Symbol] attribute or string condition items will be grouped.
      # @param _parent_name [String] stores the group parent name of this instance if has one.
      def initialize(_name, _grouping_criteria = nil, _parent_name = nil)
        set_grouping_criteria(_name, _grouping_criteria)
        set_group_name(_name)
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

      # Applies grouping criteria.
      #
      # @param _item [Organizer::Source::Item]
      # @return [Object]
      def apply_grouping_criteria(_item)
        return _item.send(self.group_by_attr) if self.group_by_attr
        return self.grouping_condition.call(_item) if self.grouping_condition
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

        @grouping_criteria = self.group_by_attr || _criteria
      end

      def set_group_name(_name)
        _name = self.group_by_attr if !_name && !!self.group_by_attr
        raise_error(:group_name_is_mandatory) unless _name
        @item_name = _name
        @group_name = _name
      end
    end
  end
end
