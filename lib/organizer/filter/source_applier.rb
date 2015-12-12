module Organizer
  module Filter
    module SourceApplier
      include Organizer::Error
      extend Organizer::Filter::Applier

      def self.apply(_filters, _collection)
        filter_collection(_filters, _collection)
      end
    end
  end
end
