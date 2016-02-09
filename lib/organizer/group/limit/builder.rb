module Organizer
  module Group
    module Limit
      module Builder
        include Organizer::Error
        extend Organizer::Limit::Builder

        def self.build(_limit_methods, _group_definitions)
          return _group_definitions if _limit_methods.blank? || _group_definitions.blank?

          _limit_methods.each do |group_name, limit_items|
            definition = _group_definitions.find_by_name(group_name)
            raise_error(:unknown_group) unless definition
            definition.limit_item = build_limit_item(limit_items.first)
          end

          _group_definitions
        end
      end
    end
  end
end
