module Organizer
  module Group
    class Collection < Array
      include Organizer::Error

      def <<(_item)
        raise_error(:invalid_item) if !_item.is_a?(Organizer::Group::Item)
        super
      end

      # Find group by name
      #
      # param _name [Symbol] group's name
      # @return [Organizer::Group::Item]
      def group_by_name _name
        return unless _name
        self.find { |group| group.has_name?(_name) }
      end
    end
  end
end
