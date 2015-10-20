module Organizer
  module Filter
    module Selector
      include Organizer::Error

      def self.select_default(_filters, _collection_methods)
        skip_methods = _collection_methods.select(&:skip_default_filters?)
        return _filters if skip_methods.empty?
        skip_all = skip_methods.find { |m| m.array_args_include?(:all) }
        filters_to_skip = skip_methods.map(&:args).flatten
        return if skip_all || filters_to_skip.blank?
        _filters.reject_items(filters_to_skip)
      end

      def self.select_filters(_filters, _methods)
        selected = filters_from_methods(_methods)
        return if selected.keys.empty?
        selected_filters = Organizer::Filter::Collection.new

        selected.each do |filter_name, value|
          filter = _filters.find_by_name(filter_name)

          if filter
            filter.value = value
            selected_filters << filter
          end
        end

        selected_filters
      end

      def self.select_groups_filters(_filters, _group_methods)
        groups_filters = {}
        group_data = []

        _group_methods.reverse_each do |method|
          if method.filter_by?
            group_data << method
          elsif method.group_by? && !group_data.empty?
            group_filters = select_filters(_filters, group_data)
            groups_filters[method.args.first] = group_filters if group_filters
            group_data = []
          end
        end

        return if groups_filters.keys.empty?
        groups_filters
      end

      def self.filters_from_methods(_methods)
        filters = {}

        _methods.each do |method|
          next unless method.filter_by?
          method.args.each do |arg|
            if arg.is_a?(Hash)
              filters.merge!(arg)
            elsif arg.is_a?(Symbol) || arg.is_a?(String)
              filters[arg] = nil
            end
          end
        end

        filters
      end
    end
  end
end
