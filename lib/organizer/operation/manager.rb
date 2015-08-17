module Organizer
  module Operation
    class Manager
      include Organizer::Error

      # Creates a new {Organizer::Operation::Simple} and adds to operations collection.
      #
      # @param _name [Symbol] operation's name
      # @yield contains logic to generate the result for this particular operation.
      # @yieldparam organizer_item [Organizer::Source::Item] you can use item's attributes to get the desired operation result.
      # @return [Organizer::Operation::Simple]
      def add_operation(_name, &block)
        operations << Organizer::Operation::Simple.new(block, _name)
        operations.last
      end

      # Creates a new {Organizer::Operation::Memo} and adds to group operations collection.
      #
      # @param _name [Symbol] operation's name
      # @param _initial_value [Object]
      # @yield contains logic to generate the result for this particular operation.
      # @return [Organizer::Operation::Simple]
      def add_group_operation(_name, _initial_value = 0, &block)
        group_operations << Organizer::Operation::Memo.new(block, _name, _initial_value)
        group_operations.last
      end

      # Each source collection item will be evaluated against defined operations. The operation's results
      # will be attached to items as new attributes.
      #
      # @param _collection [Organizer::Source::Collection]
      # @return [Organizer::Source::Collection] the collection with new attached attributes.
      #
      # @raise [Organizer::Operation::ManagerException]
      def execute_over_source_items(_collection)
        return unless _collection.is_a?(Organizer::Source::Collection)
        return _collection if operations.count <= 0
        _collection.each { |item| execute_recursively(item, operations.dup) }
        _collection
      end

      # Each group collection item (and descendants) will be evaluated against defined operations.
      # The operation's results will be attached to items as new attributes.
      #
      # @param _source_collection [Organizer::Source::Collection]
      # @param _source_collection [Organizer::Group::Collection]
      # @return [Organizer::Group::Collection] the collection with new attached attributes.
      def execute_over_group_items(_source_collection, _group_collection)
        return unless _source_collection.is_a?(Organizer::Source::Collection)
        return unless _group_collection.is_a?(Organizer::Group::Collection)
        return _group_collection if group_operations.count <= 0
        _group_collection.each { |item| execute_recursively(item, group_operations.dup) }
        _group_collection
        # TODO: calculate operations for groups
      end

      private

      def execute_recursively(_item, _operations, _previous_operations_count = 0)
        return _item if _operations.size.zero?

        if _previous_operations_count == _operations.size
          raise_error(_operations.get_errors)
        end

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

      def operations
        @operations ||= Organizer::Operation::Collection.new
      end

      def group_operations
        @group_operations ||= Organizer::Operation::Collection.new
      end
    end
  end
end
