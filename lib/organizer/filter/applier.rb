module Organizer
  module Filter
    class Applier
      include Organizer::Error

      # Applies default filters to given collection.
      #   To skip a default filter, need to pass default filter names inside array in _filter_by.
      #   If you want to skip all default filters, _filter_by need to be :all symbol.
      #
      # @param _filters [Organizer::Filter::Collection] default filters collection
      # @param _collection [Organizer::Source::Collection] the whole collection
      # @param _filter_by [Array, Symbol] :all symbol or Array with filter names
      # @return [Organizer::Source::Collection] a filtered collection
      def self.apply_default(_filters, _collection, _filter_by = [])
        selected_filters = (_filter_by == :all) ? nil : _filters.reject_items(_filter_by)
        apply_filters(selected_filters, _collection)
      end

      # Applies filters to a given collection.
      #   To apply a normal filter, need to pass filter names inside array in _filter_by like this:
      #   [:my_filter, :other_filter]. or
      #   need to pass filter_key filter_value pairs in _filter_by like this:
      #   { my_filter: 4, other_filter: 6 }.
      #
      # @param _filters [Organizer::Filter::Collection] filters collection
      # @param _collection [Organizer::Source::Collection] the whole collection
      # @param _filter_by [Array, Hash]
      # @return [Organizer::Source::Collection] a filtered collection
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
