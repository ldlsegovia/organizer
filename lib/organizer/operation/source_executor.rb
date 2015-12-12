module Organizer
  module Operation
    module SourceExecutor
      include Organizer::Error

      def self.execute(_operations, _source_collection)
        _source_collection.each { |item| execute_recursively(item, _operations.dup) }
        _source_collection
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
