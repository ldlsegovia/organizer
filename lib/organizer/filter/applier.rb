module Organizer
  module Filter
    class Applier
      include Organizer::Error

      def self.apply(_filters, _collection, _options = {})
        if _options.has_key?(:skipped_filters)
          return apply_skipping_filters(_filters, _collection, _options[:skipped_filters])

        elsif _options.has_key?(:selected_filters)
          return apply_selecting_filters(_filters, _collection, _options[:selected_filters])

        elsif _options.has_key?(:groups_filters)
          apply_groups_filters(_filters, _collection, _options[:groups_filters])
          return _collection
        end

        _collection
      end

      def self.apply_skipping_filters(_filters, _collection, _skipped_filters)
        selected_filters = (_skipped_filters == :all) ? nil : _filters.reject_items(_skipped_filters)
        apply_filters(selected_filters, _collection)
      end

      def self.apply_selecting_filters(_filters, _collection, _selected_filters)
        filter_pairs = {}

        if _selected_filters.is_a?(Hash)
          filter_pairs = _selected_filters
          _selected_filters = _selected_filters.keys
        end

        selected_filters = _filters.select_items(_selected_filters)
        apply_filters(selected_filters, _collection, filter_pairs)
      end

      def self.apply_groups_filters(_filters, _collection, _groups_filters)
        return if _collection.empty?
        return unless _collection.first.is_a?(Organizer::Group::Item)
        group_filters = _groups_filters[_collection.first.group_name]
        selected_filters = !!group_filters ? _filters.select_items(group_filters.keys) : []
        apply_filters(selected_filters, _collection, group_filters)
        _collection.each { |item| apply_groups_filters(_filters, item, _groups_filters) }
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
