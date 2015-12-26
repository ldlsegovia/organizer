module Organizer
  module Operation
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Operation::Item

      def add(_name, _options = {}, &block)
        self << Organizer::Operation::Item.new(block, _name, _options)
        last
      end

      def get_errors
        select(&:has_error?).map { |operation| operation.error.message }.join(', ')
      end
    end
  end
end
