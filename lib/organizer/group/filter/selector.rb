module Organizer
  module Group
    module Filter
      module Selector
        include Organizer::Error
        extend Organizer::Filter::Selector

        def self.select(_filters, _group_filter_methods, _group_definitions)
          if _filters.blank? || _group_filter_methods.blank? || _group_definitions.blank?
            return _group_definitions
          end

          _group_filter_methods.each do |group_name, filters|
            definition = _group_definitions.find_by_name(group_name)
            raise_error(:unknown_group) unless definition
            definition.filters = select_filters(_filters, filters)
          end

          _group_definitions
        end
      end
    end
  end
end
