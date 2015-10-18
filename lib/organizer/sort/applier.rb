module Organizer
  module Sort
    class Applier
      include Organizer::Error

      def self.apply_on_source(_sort_items, _source_collection)
        sort(_sort_items, _source_collection)
      end

      def self.apply_on_groups(_groups_sort_items, _groups_collection)
        return if _groups_collection.empty?
        return unless _groups_collection.first.is_a?(Organizer::Group::Item)
        group_sort_items = _groups_sort_items[_groups_collection.first.group_name] || []
        sort(group_sort_items, _groups_collection)
        _groups_collection.each { |item| apply_on_groups(_groups_sort_items, item) }
      end

      def self.sort(_sort_items, _collection)
        return _collection unless _sort_items && !_sort_items.empty?
        _collection.sort! do |item, next_item|
          compare_items(_sort_items, item, next_item)
        end
      end

      def self.compare_items(_sort_items, _item_one, _item_two)
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
