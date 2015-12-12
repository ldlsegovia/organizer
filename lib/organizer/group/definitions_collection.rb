module Organizer
  module Group
    class DefinitionsCollection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::Definition

      def add_definition(_group_name, _group_by_attr = nil)
        self << Organizer::Group::Definition.new(_group_name, _group_by_attr)
        last
      end

      def groups_from_definitions
        groups = Organizer::Group::Collection.new

        each do |item|
          if item.is_a?(Organizer::Group::Definition)
            groups.add_group(item.item_name, item.group_by_attr)
          end
        end

        groups
      end

      def children_based_operations(_group_name)
        find_if_definition(_group_name, :children_based_operations)
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
