module Organizer
  module Group
    module Sort
      module Builder
        include Organizer::Error
        extend Organizer::Sort::Builder

        def self.build(_sort_methods, _group_definitions)
          return _group_definitions if _sort_methods.blank? || _group_definitions.blank?

          _sort_methods.each do |group_name, sort_items|
            definition = _group_definitions.find_by_name(group_name)
            raise_error(:unknown_group) unless definition
            group_sort_items = build_sort_items(sort_items)
            definition.sort_items = group_sort_items if group_sort_items
          end

          _group_definitions
        end
      end
    end
  end
end
