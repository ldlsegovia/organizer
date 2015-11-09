module Organizer
  module Group
    module Selector
      include Organizer::Error

      def self.select(_groups_definitions, _group_method)
        return if _group_method.blank?
        group_definitions = _groups_definitions[_group_method.group_name.to_sym]
        raise_error(:unknown_group) unless group_definitions
        group_definitions.clone
      end
    end
  end
end
