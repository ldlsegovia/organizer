module Organizer
  module Source
    module Filter
      module Selector
        include Organizer::Error
        extend Organizer::Filter::Selector

        def self.select_default(_filters, _skip_filter_methods)
          return _filters if _skip_filter_methods.empty?
          skip_all = _skip_filter_methods.find { |m| m.array_args_include?(:all) }
          filters_to_skip = _skip_filter_methods.map(&:args).flatten
          return if skip_all || filters_to_skip.blank?
          _filters.reject_items(filters_to_skip)
        end

        def self.select(_filters, _filter_methods)
          select_filters(_filters, _filter_methods)
        end
      end
    end
  end
end
