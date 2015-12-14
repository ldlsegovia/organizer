module Organizer
  module Filter
    module Applier
      def filter_collection(_filters, _collection)
        return _collection unless _filters

        _collection.reject! do |item|
          keep_item = true

          _filters.each do |filter|
            if !filter.apply(item)
              keep_item = false
              break
            end
          end

          !keep_item
        end

        _collection
      end
    end
  end
end
