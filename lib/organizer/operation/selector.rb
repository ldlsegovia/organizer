module Organizer
  module Operation
    module Selector
      include Organizer::Error

      def self.select_group_operations(_global_operations, _group_definitions)
        _group_definitions.each do |group_definition|
          _global_operations.each do |operation|
            group_definition.add_memo_operation(operation)
          end
        end

        _group_definitions
      end
    end
  end
end
