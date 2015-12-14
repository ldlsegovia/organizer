module Organizer
  module Group
    module Filter
      module Selector
        include Organizer::Error
        extend Organizer::Filter::Selector

        def self.select(_filters, _group_filter_methods, _group_definitions)
          return unless _group_definitions

          _group_filter_methods.each do |group_name, filters|
            definition = _group_definitions.find_by_name(group_name)
            raise_error(:unknown_group) unless definition
            group_filters = select_filters(_filters, filters)
            definition.filters = group_filters if group_filters
          end

          return if _group_definitions.empty?
          _group_definitions
        end
      end
    end
  end
end
