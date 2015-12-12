module Organizer
  module Operation
    module Executor
      include Organizer::Error

      def self.execute_on_source(_operations, _source_collection)
        _source_collection.each { |item| execute_recursively(item, _operations.dup) }
        _source_collection
      end

      def self.execute_on_groups(_group_definitions, _source_collection, _group_collection)
        _source_collection.each do |source_item|
          _group_collection.each do |group_item|
            eval_operations_against_groups(_group_definitions, source_item, [group_item])
          end
        end

        _group_collection
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
        group_operations = _group_definitions.memo_operations(_group_item.group_name)
        return unless group_operations
        group_operations.each { |operation| operation.execute(_group_item, _source_item) }
      end

      def self.item_match_with_group_hierarchy?(_group_items_hierarchy, _source_item)
        result = _group_items_hierarchy.map do |gi|
          gi.apply(_source_item).to_s === gi.item_name.to_s
        end.uniq

        result.size == 1 && !!result.first
      end

      def self.execute_recursively(_item, _operations, _previous_operations_count = 0)
        return _item if _operations.size.zero?
        raise_error(_operations.get_errors) if _previous_operations_count == _operations.size

        _non_executed_operations = Organizer::Operation::Collection.new
        _previous_operations_count = _operations.size

        _operations.each do |operation|
          begin
            operation.execute(_item)
          rescue => e
            operation.error = e
            _non_executed_operations << operation
          end
        end

        if _non_executed_operations.size > 0
          execute_recursively(_item, _non_executed_operations, _previous_operations_count)
        end
      end
    end
  end
end
