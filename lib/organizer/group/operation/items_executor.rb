module Organizer
  module Group
    module Operation
      module ItemsExecutor
        include Organizer::Error

        def self.execute(_group_definitions, _group_items_collection)
          _group_items_collection.each do |group_item|
            eval_operations_against_groups(_group_definitions, [group_item])
          end
        end

        def self.eval_operations_against_groups(_group_definitions, _group_items_hierarchy)
          group_item = _group_items_hierarchy.last
          return unless group_item.is_a?(Organizer::Group::Item)

          execute_group_operations(_group_definitions, group_item)

          group_item.each do |child|
            break unless child.is_a?(Organizer::Group::Item)
            new_hierarchy = _group_items_hierarchy.clone
            new_hierarchy << child
            eval_operations_against_groups(_group_definitions, new_hierarchy)
          end
        end

        def self.execute_group_operations(_group_definitions, _group_item)
          operations = _group_definitions.item_operations(_group_item.group_name)
          return unless operations
          operations.each { |operation| operation.execute(_group_item) }
        end
      end
    end
  end
end
