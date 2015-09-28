module Organizer
  module Operation
    class Executor
      include Organizer::Error

      # Each source collection item will be evaluated against _operations. The operation's results
      # will be attached to items as new attributes.
      #
      # @param _operations [Organizer::Operation::Collection]
      # @param _collection [Organizer::Source::Collection]
      # @return [Organizer::Source::Collection] the collection with new attached attributes.
      #
      # @raise [Organizer::Operation::ExecutorException]
      def self.execute_on_source_items(_operations, _collection)
        return unless _collection.is_a?(Organizer::Source::Collection)
        return _collection if _operations.count <= 0
        _collection.each { |item| execute_recursively(item, _operations.dup) }
        _collection
      end

      # Each group collection item (and descendants) will be evaluated against _operations.
      # The operation's results will be attached to items as new attributes.
      #
      # @param _operations [Organizer::Operation::Collection]
      # @param _source_collection [Organizer::Source::Collection]
      # @param _group_collection [Organizer::Group::Collection]
      # @return [Organizer::Group::Collection] the collection with new attached attributes.
      def self.execute_on_group_items(_operations, _source_collection, _group_collection)
        return unless _source_collection.is_a?(Organizer::Source::Collection)
        return unless _group_collection.is_a?(Organizer::Group::Collection)
        return _group_collection if _operations.count <= 0

        _source_collection.each do |source_item|
          _group_collection.each do |group_item|
            eval_operations_against_groups(_operations, source_item, [group_item])
          end
        end

        _group_collection
      end

      def self.eval_operations_against_groups(_operations, _source_item, _group_items_hierarchy)
        group_item = _group_items_hierarchy.last
        return unless group_item.is_a?(Organizer::Group::Item)

        result = _group_items_hierarchy.map do |gi|
          _source_item.send(gi.grouping_criteria).to_s === gi.item_name.to_s
        end.uniq

        if result.size == 1 && !!result.first
          _operations.each { |operation| operation.execute(group_item, _source_item) }
        end

        group_item.each do |child|
          break unless child.is_a?(Organizer::Group::Item)
          new_hierarchy = _group_items_hierarchy.clone
          new_hierarchy << child
          eval_operations_against_groups(_operations, _source_item, new_hierarchy)
        end
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
