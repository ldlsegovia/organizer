module Organizer
  module Filter
    class Generator
      include Organizer::Error
      # Generates common filters based on _item attributes. If you have an {Organizer::Source::Item} with a single
      #   attribute named "my_attr". After run this method you will have these filters:
      #   * my_attr_eq: match attribute equals to...
      #   * my_attr_not_eq: match attribute different to...
      #   * my_attr_gt: match attribute greater than...
      #   * my_attr_lt: match attribute lower than...
      #   * my_attr_goet: match attribute greater or equal than...
      #   * my_attr_loet: match attribute lower or equal than...
      #   * my_attr_contains: match attribute containing string...
      #   * my_attr_starts: match attribute starting with string...
      #   * my_attr_ends: match attribute ending with string...
      def self.generate(_item)
        filters = Organizer::Filter::Collection.new
        return filters unless _item

        raise_error(:generate_over_organizer_items_only) unless _item.is_a? Organizer::Source::Item
        _item.attribute_names.each do |attribute|
          generate_attr_filter(filters, attribute, :eq) { |item, value| item.send(attribute) == value }
          generate_attr_filter(filters, attribute, :not_eq) { |item, value| item.send(attribute) != value }
          generate_attr_filter(filters, attribute, :gt) { |item, value| item.send(attribute) > value }
          generate_attr_filter(filters, attribute, :goet) { |item, value| item.send(attribute) >= value }
          generate_attr_filter(filters, attribute, :lt) { |item, value| item.send(attribute) < value }
          generate_attr_filter(filters, attribute, :loet) { |item, value| item.send(attribute) <= value }
          generate_attr_filter(filters, attribute, :contains) { |item, value| !!item.send(attribute).to_s[value.to_s] }
          generate_attr_filter(filters, attribute, :starts) { |item, value| item.send(attribute).to_s.start_with?(value.to_s) }
          generate_attr_filter(filters, attribute, :ends) { |item, value| item.send(attribute).to_s.end_with?(value.to_s) }
        end

        filters
      end

      private

      def self.generate_attr_filter(_filters, _attr, _sufix, &proc)
        filter_name = "#{_attr}_#{_sufix}"
        _filters.add_filter_with_value(filter_name, &proc)
      end
    end
  end
end
