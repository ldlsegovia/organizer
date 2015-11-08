module Organizer
  module GroupDefinition
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::GroupDefinition::Item

      def add_definition(_group_name, _group_by_attr = nil, _parent_name = nil)
        self << Organizer::GroupDefinition::Item.new(_group_name, _group_by_attr, _parent_name)
        last
      end

      def find_or_create_definition(_group)
        definition = find_by_name(_group.group_name)
        return definition if definition
        add_definition(_group.group_name, _group.group_by_attr, _group.parent_name)
      end

      def add_memo_operation(_group_name, _operation, _initial_value = 0, &block)
        in_definition_context(_group_name) do |group_definition|
          if _operation.is_a?(Organizer::Operation::Memo)
            group_definition.add_memo_operation(_operation)
          else
            operation = Organizer::Operation::Memo.new(block, _operation, _initial_value)
            group_definition.add_memo_operation(operation)
          end
        end
      end

      def memo_operations(_group_name)
        find_if_definition(_group_name, :memo_operations)
      end

      def sort_items(_group_name)
        find_if_definition(_group_name, :sort_items)
      end

      def filters(_group_name)
        find_if_definition(_group_name, :filters)
      end

      private

      def find_if_definition(_group_name, _collection_method)
        definition = find_by_name(_group_name)
        return unless definition
        definition.send(_collection_method)
      end

      def in_definition_context(_group_name)
        defintion = find_by_name(_group_name)
        raise_error(:definition_not_found) unless defintion
        yield(defintion)
      end
    end
  end
end
