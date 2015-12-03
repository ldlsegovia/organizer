module Organizer
  module Operation
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Operation::Simple, Organizer::Operation::Memo

      def add_simple_operation(_name, _options = {}, &block)
        self << Organizer::Operation::Simple.new(block, _name, _options)
        last
      end

      def add_mask_operation(_attribute, _mask, _options = {})
        self << Organizer::Operation::MaskBuilder.build(_attribute, _mask, _options)
        last
      end

      def add_memo_operation(_name, _initial_value = 0, _options = {}, &block)
        self << Organizer::Operation::Memo.new(block, _name, _initial_value, _options)
        last
      end

      def get_errors
        select(&:has_error?).map { |operation| operation.error.message }.join(', ')
      end
    end
  end
end
