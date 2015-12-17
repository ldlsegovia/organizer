module Organizer
  module Sort
    module Applier
      def sort_collection(_sort_items, _collection)
        return _collection if _sort_items.blank? || _collection.blank?
        _collection.sort! do |item, next_item|
          compare_items(_sort_items, item, next_item)
        end
      end

      def compare_items(_sort_items, _item_one, _item_two)
        side_one = []
        side_two = []

        _sort_items.each do |sort_item|
          a = _item_one.send(sort_item.item_name)
          b = _item_two.send(sort_item.item_name)

          if sort_item.descending
            side_one << b
            side_two << a
          else
            side_one << a
            side_two << b
          end

          break if a != b
        end

        side_one <=> side_two
      end
    end
  end
end
