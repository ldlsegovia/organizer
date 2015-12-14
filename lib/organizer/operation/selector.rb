module Organizer
  module Operation
    module Selector
      include Organizer::Error

      def self.select_group_operations(_global_operations, _group_definitions)
        return _group_definitions if _global_operations.empty? || _group_definitions.blank?

        _group_definitions.each do |group_definition|
          _global_operations.each do |operation|
            group_definition.add_children_based_operation(operation)
          end
        end

        _group_definitions
      end
    end
  end
end
