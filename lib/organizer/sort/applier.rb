module Organizer
  module Sort
    class Applier
      include Organizer::Error

      def self.apply(_sort_items, _collection)
        if _collection.is_a?(Organizer::Source::Collection)
          return sort(_sort_items, _collection)

        elsif _collection.is_a?(Organizer::Group::Collection)
          # TODO
          return
        end

        _collection
      end

      def self.sort(_sort_items, _collection)
        return _collection unless _sort_items

        _collection.sort! do |first_item, second_item|
          side_one = []
          side_two = []

          _sort_items.each do |sort_item|
            a = first_item.send(sort_item.item_name)
            b = second_item.send(sort_item.item_name)

            if sort_item.descendant
              side_one << b
              side_two << a
            else
              side_one << a
              side_two << b
            end
          end

          side_one <=> side_two
        end
      end
    end
  end
end
