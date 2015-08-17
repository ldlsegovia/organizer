module Organizer
  module Operation
    class GroupCollection < Organizer::Operation::SourceItem
      attr_reader :initial_value

      # @param _definition [Proc] contains logic to generate the value for this operation
      # @param _name [Symbol] symbol to identify this particular operation
      # @param _initial_value [Object]
      def initialize(_definition, _name, _initial_value = 0)
        @initial_value = _initial_value
        super(_definition, _name)
      end

      # Evaluates definition proc to build a new attribute. This attribute will be added to _group_item param.
      #
      # @param _group_item [Organizer::Group::Item]
      # @return [void]
      #
      # @raise [Organizer::Operation::GroupCollectionException] :execute_over_organizer_group_items_only
      def execute(_group_item)
        raise_error(:execute_over_organizer_group_items_only) if !_group_item.is_a?(Organizer::Group::Item)
        _group_item.define_attribute(self.item_name, self.initial_value, false)
        _group_item.each do |item|
          result = definition.call(_group_item.send(self.item_name), item)
          _group_item.send("#{self.item_name}=", result)
        end
        return
      end
    end
  end
end
