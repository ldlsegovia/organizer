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
            if sort_item.descendant
              side_one << second_item.send(sort_item.item_name)
              side_two << first_item.send(sort_item.item_name)
            else
              side_one << first_item.send(sort_item.item_name)
              side_two << second_item.send(sort_item.item_name)
            end
          end

          side_one <=> side_two
        end

        _collection
      end
    end
  end
end
