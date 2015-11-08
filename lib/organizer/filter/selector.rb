module Organizer
  module Filter
    module Selector
      include Organizer::Error

      def self.select_default(_filters, _collection_methods)
        skip_methods = _collection_methods.select(&:skip_default_filter?)
        return _filters if skip_methods.empty?
        skip_all = skip_methods.find { |m| m.array_args_include?(:all) }
        filters_to_skip = skip_methods.map(&:args).flatten
        return if skip_all || filters_to_skip.blank?
        _filters.reject_items(filters_to_skip)
      end

      def self.select_filters(_filters, _filter_methods)
        return if !_filter_methods || _filter_methods.keys.empty?
        selected_filters = Organizer::Filter::Collection.new

        _filter_methods.each do |filter_name, value|
          filter = _filters.find_by_name(filter_name)

          if filter
            filter.value = value
            selected_filters << filter
          end
        end

        selected_filters
      end

      def self.select_groups_filters(_filters, _group_filter_methods, _group_definitions)
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
