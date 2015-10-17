module Organizer
  module Filter
    class Applier
      include Organizer::Error

      def self.apply_except_skipped(_filters, _source_collection, _skipped_filter_names = nil)
        selected_filters = _filters.reject_items(_skipped_filter_names) unless _skipped_filter_names == :all
        apply_filters(selected_filters, _source_collection)
      end

      def self.apply_selected(_filters, _source_collection, _selected_filters = {})
        filter_pairs = {}

        if _selected_filters.is_a?(Hash)
          filter_pairs = _selected_filters
          _selected_filters = _selected_filters.keys
        end

        selected_filters = _filters.select_items(_selected_filters)
        apply_filters(selected_filters, _source_collection, filter_pairs)
      end

      def self.apply_selected_on_groups(_filters, _groups_collection, _selected_filters)
        return if _groups_collection.empty?
        return unless _groups_collection.first.is_a?(Organizer::Group::Item)
        group_filters = _selected_filters[_groups_collection.first.group_name]
        selected_filters = !!group_filters ? _filters.select_items(group_filters.keys) : []
        apply_filters(selected_filters, _groups_collection, group_filters)
        _groups_collection.each { |item| apply_selected_on_groups(_filters, item, _selected_filters) }
      end

      def self.apply_filters(_filters, _collection, _filters_values = nil)
        return _collection unless _filters

        _collection.reject! do |item|
          keep_item = true

          _filters.each do |filter|
            value = get_filter_value(filter, _filters_values)

            if !filter.apply(item, value)
              keep_item = false
              break
            end
          end

          !keep_item
        end

        _collection
      end

      def self.get_filter_value(_filter, _filters_values)
        return if !_filters_values || !_filter.item_name
        _filters_values[_filter.item_name] || _filters_values[_filter.item_name.to_sym]
      end
    end
  end
end
