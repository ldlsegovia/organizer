module Organizer
  module Source
    module Sort
      module Applier
        include Organizer::Error
        extend Organizer::Sort::Applier

        def self.apply(_sort_items, _collection)
          sort_collection(_sort_items, _collection)
        end
      end
    end
  end
end
