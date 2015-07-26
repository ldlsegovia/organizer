module Organizer
  module Operation
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Operation::SourceItem, Organizer::Operation::GroupCollection

      # Builds a string containing operation errors
      #
      # @return [String]
      def get_errors
        self.select {|o| o.has_error? }.map {|operation| operation.error.message }.join(', ')
      end
    end
  end
end
