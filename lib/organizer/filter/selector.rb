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
        return if _filter_methods.keys.empty?
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

      def self.select_groups_filters(_filters, _group_filter_methods)
        groups_filters = {}

        _group_filter_methods.keys.each do |group_name|
          group_filters = select_filters(_filters, _group_filter_methods[group_name])
          groups_filters[group_name] = group_filters if group_filters
        end

        return if groups_filters.keys.empty?
        groups_filters
      end
    end
  end
end
