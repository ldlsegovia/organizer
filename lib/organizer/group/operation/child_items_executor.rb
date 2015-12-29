module Organizer
  module Group
    module Operation
      module ChildItemsExecutor
        include Organizer::Error

        def self.execute(_group_definitions, _group_items_collection)
          _group_items_collection.each do |item|
            parents = Organizer::Group::Collection.new
            eval_operations_against_groups(_group_definitions, item, parents)
          end
        end

        def self.eval_operations_against_groups(_group_definitions, _item, _parents)
          execute_group_operations(_group_definitions, _item, _parents)

          return unless _item.is_a?(Organizer::Group::Item)

          _item.each do |child|
            current_parents = _parents.clone
            current_parents.unshift(_item)
            eval_operations_against_groups(_group_definitions, child, current_parents)
          end
        end

        def self.execute_group_operations(_group_definitions, _item, _parents)
          return if _parents.empty?
          operations = _group_definitions.child_item_operations(_parents.first.group_name)
          return unless operations
          operations.each { |operation| operation.execute(_item, _parents) }
        end
      end
    end
  end
end
