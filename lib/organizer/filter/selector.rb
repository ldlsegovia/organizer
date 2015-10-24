module Organizer
  module Filter
    module Selector
      include Organizer::Error
      extend Organizer::ChainedMethodsHelpers

      def self.select_default(_filters, _collection_methods)
        skip_methods = _collection_methods.select(&:skip_default_filters?)
        return _filters if skip_methods.empty?
        skip_all = skip_methods.find { |m| m.array_args_include?(:all) }
        filters_to_skip = skip_methods.map(&:args).flatten
        return if skip_all || filters_to_skip.blank?
        _filters.reject_items(filters_to_skip)
      end

      def self.select_filters(_filters, _methods)
        selected = methods_to_hash(_methods, :filter_by)
        return if selected.keys.empty?
        selected_filters = Organizer::Filter::Collection.new

        selected.each do |filter_name, value|
          filter = _filters.find_by_name(filter_name)

          if filter
            filter.value = value
            selected_filters << filter
          end
        end

        selected_filters
      end

      def self.select_groups_filters(_filters, _group_methods)
        groups_filters = {}

        for_each_group_methods(_group_methods, :filter_by) do |group_name, filter_methods|
          group_filters = select_filters(_filters, filter_methods)
          groups_filters[group_name] = group_filters if group_filters
        end

        return if groups_filters.keys.empty?
        groups_filters
      end
    end
  end
end
