module Organizer
  module GroupDefinition
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::GroupDefinition::Item

      def add_definition(_group_name)
        self << Organizer::GroupDefinition::Item.new(_group_name)
        last
      end

      def add_memo_operation(_group_name, _operation_name, _initial_value = 0, &block)
        in_definition_context(_group_name) do |group_definition|
          group_definition.add_memo_operation(_operation_name, _initial_value, &block)
        end
      end

      def memo_operations(_group_name)
        definition = find_by_name(_group_name)
        return unless definition
        definition.memo_operations
      end

      private

      def in_definition_context(_group_name)
        defintion = find_by_name(_group_name)
        raise_error(:definition_not_found) unless defintion
        yield(defintion)
      end
    end
  end
end
