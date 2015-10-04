module Organizer
  module Filter
    class Applier
      include Organizer::Error

      def self.apply_default(_filters, _collection, _filter_by = [])
        selected_filters = (_filter_by == :all) ? nil : _filters.reject_items(_filter_by)
        apply_filters(selected_filters, _collection)
      end

      def self.apply(_filters, _collection, _filter_by = [])
        filter_pairs = {}

        if _filter_by.is_a?(Hash)
          filter_pairs = _filter_by
          _filter_by = _filter_by.keys
        end

        selected_filters = _filters.select_items(_filter_by)
        apply_filters(selected_filters, _collection, filter_pairs)
      end

      def self.apply_filters(_filters, _collection, _filters_values = nil)
        return _collection unless _filters
        filtered_collection = Organizer::Source::Collection.new
        _collection.each do |item|
          add_item = true

          _filters.each do |filter|
            value = get_filter_value(filter, _filters_values)

            if !filter.apply(item, value)
              add_item = false
              break
            end
          end

          filtered_collection << item if add_item
        end

        filtered_collection
      end

      def self.get_filter_value(_filter, _filters_values)
        return if !_filters_values || !_filter.item_name
        _filters_values[_filter.item_name] || _filters_values[_filter.item_name.to_sym]
      end
    end
  end
end
