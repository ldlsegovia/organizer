module Organizer
  module Filter
    class Applier
      include Organizer::Error

      # Applies default filters to given collection.
      #   To skip a default filter, need to pass default filter names inside array in _options like this:
      #   { skip_default_filters: [my_filter] }.
      #   If you want to skip all default filters: { skip_default_filters: :all }.
      #
      # @param _filters [Organizer::Filter::Collection] default filters collection
      # @param _collection [Organizer::Source::Collection] the whole collection
      # @param _options [Hash]
      # @return [Organizer::Source::Collection] a filtered collection
      def self.apply_default_filters(_filters, _collection, _options = {})
        filter_by = _options.fetch(:skip_default_filters, [])
        selected_filters = (filter_by == :all) ? nil : _filters.reject_items(filter_by)
        apply_filters(selected_filters, _collection)
      end

      # Applies normal filters to a given collection.
      #   To apply a normal filter, need to pass filter names inside array in _options like this:
      #   { enabled_filters: [my_filter] }.
      #
      # @param _filters [Organizer::Filter::Collection] normal filters collection
      # @param _collection [Organizer::Source::Collection] the whole collection
      # @param _options [Hash]
      # @return [Organizer::Source::Collection] a filtered collection
      def self.apply_normal_filters(_filters, _collection, _options = {})
        filter_names = _options.fetch(:enabled_filters, [])
        selected_filters = _filters.select_items(filter_names)
        apply_filters(selected_filters, _collection)
      end

      # Applies filters (with value) to a given collection.
      #   To apply filters with values, need to pass filter_key filter_value pairs in _options like this:
      #   { my_filter: 4, other_filter: 6 }.
      #
      # @param _filters [Organizer::Filter::Collection] filters with value collection
      # @param _collection [Organizer::Source::Collection] the whole collection
      # @param _options [Hash]
      # @return [Organizer::Source::Collection] a filtered collection
      def self.apply_filters_with_values(_filters, _collection, _options = {})
        filter_pairs = _options.fetch(:filters, {})
        selected_filters = _filters.select_items(filter_pairs.keys)
        apply_filters(selected_filters, _collection, filter_pairs)
      end

      private

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
        return if !_filter.accept_value || !_filters_values || !_filter.item_name
        _filters_values[_filter.item_name] || _filters_values[_filter.item_name.to_sym]
      end
    end
  end
end
