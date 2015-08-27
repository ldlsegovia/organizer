module Organizer
  module Operation
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Operation::Simple, Organizer::Operation::Memo

      # Creates a new {Organizer::Operation::Simple} and adds to collection.
      #
      # @param _name [Symbol] operation's name
      # @yield contains logic to generate the result for this particular operation.
      # @yieldparam organizer_item [Organizer::Source::Item] you can use item's attributes to get the desired operation result.
      # @return [Organizer::Operation::Simple]
      def add_simple_operation(_name, &block)
        self << Organizer::Operation::Simple.new(block, _name)
        self.last
      end

      # Creates a new {Organizer::Operation::Memo} and adds to collection.
      #
      # @param _name [Symbol] operation's name
      # @param _initial_value [Object]
      # @yield contains logic to generate the result for this particular operation.
      # @return [Organizer::Operation::Simple]
      def add_memo_operation(_name, _initial_value = 0, &block)
        self << Organizer::Operation::Memo.new(block, _name, _initial_value)
        self.last
      end

      # Builds a string containing operation errors
      #
      # @return [String]
      def get_errors
        self.select {|o| o.has_error? }.map {|operation| operation.error.message }.join(', ')
      end
    end
  end
end
