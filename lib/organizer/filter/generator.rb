module Organizer
  module Filter
    module Generator
      include Organizer::Error

      def self.generate(_attribute_names)
        filters = Organizer::Filter::Collection.new

        _attribute_names.each do |attribute|
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

      def self.generate_attr_filter(_filters, _attr, _sufix, &proc)
        filter_name = "#{_attr}_#{_sufix}".to_sym
        _filters.add(filter_name, &proc)
      end
    end
  end
end
