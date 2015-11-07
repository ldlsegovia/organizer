module Organizer
  module Operation
    module Selector
      include Organizer::Error

      def self.select_group_operations(_groups_operations, _groups_definitions, _groups)
        groups_operations = {}

        _groups.each do |group|
          group_name = group.group_name

          if !groups_operations[group_name]
            groups_operations[group_name] = Organizer::Operation::Collection.new
          end

          load_operations(groups_operations[group_name], _groups_operations)
          group_operations = _groups_definitions.memo_operations(group_name)
          load_operations(groups_operations[group_name], group_operations)
        end

        return if groups_operations.keys.empty?

        groups_operations
      end

      def self.load_operations(_collection, _operations)
        return unless _operations
        _operations.each do |operation|
          _collection << operation
        end
      end
    end
  end
end
