module Organizer
  module Group
    module Operation
      module Loader
        include Organizer::Error

        def self.load(_definitions_keeper, _group_definitions)
          return _group_definitions if _group_definitions.blank?

          _group_definitions.each do |group_definition|
            _definitions_keeper.groups_parent_item_operations.each do |operation|
              group_definition.parent_item_operations << operation
            end

            _definitions_keeper.groups_item_operations.each do |operation|
              group_definition.item_operations << operation
            end
          end

          _group_definitions
        end
      end
    end
  end
end
