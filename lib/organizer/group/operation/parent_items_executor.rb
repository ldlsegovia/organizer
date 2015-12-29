module Organizer
  module Group
    module Operation
      module ParentItemsExecutor
        include Organizer::Error

        def self.execute(_group_definitions, _source_collection, _group_items_collection)
          _source_collection.each do |source_item|
            _group_items_collection.each do |group_item|
              eval_operations_against_groups(_group_definitions, source_item, [group_item])
            end
          end

          _group_items_collection
        end

        def self.eval_operations_against_groups(_group_definitions, _source_item, _group_items_hierarchy)
          group_item = _group_items_hierarchy.last
          return unless group_item.is_a?(Organizer::Group::Item)

          if item_match_with_group_hierarchy?(_group_items_hierarchy, _source_item)
            execute_group_operations(_group_definitions, group_item, _source_item)
          end

          group_item.each do |child|
            break unless child.is_a?(Organizer::Group::Item)
            new_hierarchy = _group_items_hierarchy.clone
            new_hierarchy << child
            eval_operations_against_groups(_group_definitions, _source_item, new_hierarchy)
          end
        end

        def self.execute_group_operations(_group_definitions, _group_item, _source_item)
          operations = _group_definitions.parent_item_operations(_group_item.group_name)
          return unless operations
          operations.each { |operation| operation.execute(_group_item, [_source_item]) }
        end

        def self.item_match_with_group_hierarchy?(_group_items_hierarchy, _source_item)
          result = _group_items_hierarchy.map do |gi|
            gi.apply(_source_item).to_s === gi.item_name.to_s
          end.uniq

          result.size == 1 && !!result.first
        end
      end
    end
  end
end
