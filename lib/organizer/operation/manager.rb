module Organizer
  module Operation
    class Manager
      include Organizer::Error

      # Creates a new {Organizer::Operation::SourceItem} and adds to operations collection.
      #
      # @param _name [Symbol] operation's name
      # @yield contains logic to generate the result for this particular operation.
      # @yieldparam organizer_item [Organizer::Source::Item] you can use item's attributes to get the desired operation result.
      # @return [Organizer::Operation::SourceItem]
      def add_operation(_name, &block)
        operations << Organizer::Operation::SourceItem.new(block, _name)
        operations.last
      end

      # Creates a new {Organizer::Operation::GroupCollection} and adds to group operations collection.
      #
      # @param _name [Symbol] operation's name
      # @param _group_name [Symbol] to identify group related with this operation
      # @param _initial_value [Object]
      # @yield contains logic to generate the result for this particular operation.
      # @return [Organizer::Operation::SourceItem]
      def add_group_operation(_name, _group_name, _initial_value = 0, &block)
        group_operations << Organizer::Operation::GroupCollection.new(block, _name, _group_name, _initial_value)
        group_operations.last
      end

      # Each collection's items will be evaluated against all defined operations. The operation's results
      # will be attached to items as new attributes.
      #
      # @param _collection [Organizer::Source::Collection] or [Organizer::Group::Collection]
      # @return [Organizer::Source::Collection] or [Organizer::Group::Collection] the collection with new attributes attached.
      #
      # @raise [Organizer::Operation::ManagerException]
      def execute(_collection)
        current_operations = _collection.is_a?(Organizer::Group::Collection) ? group_operations : operations
        return _collection if current_operations.count <= 0
        _collection.each { |item| execute_recursively(item, current_operations.dup) }
        _collection
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
