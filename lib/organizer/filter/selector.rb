module Organizer
  module Filter
    module Selector
      def select_filters(_filters, _filter_methods)
        return if !_filter_methods || _filter_methods.keys.empty?
        selected_filters = Organizer::Filter::Collection.new

        _filter_methods.each do |filter_name, value|
          filter = _filters.find_by_name(filter_name)
          raise_error(:unknown_filter) unless filter

          if filter
            filter.value = value
            selected_filters << filter
          end
        end

        selected_filters
      end
    end
  end
end
