module Organizer
  module Operation
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Operation::Simple, Organizer::Operation::Memo

      def add_simple_operation(_name, &block)
        self << Organizer::Operation::Simple.new(block, _name)
        last
      end

      def add_memo_operation(_name, _initial_value = 0, &block)
        self << Organizer::Operation::Memo.new(block, _name, _initial_value)
        last
      end

      def get_errors
        select(&:has_error?).map { |operation| operation.error.message }.join(', ')
      end
    end
  end
end
