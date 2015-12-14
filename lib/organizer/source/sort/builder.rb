module Organizer
  module Source
    module Sort
      module Builder
        include Organizer::Error
        extend Organizer::Sort::Builder

        def self.build(_sort_methods)
          build_sort_items(_sort_methods)
        end
      end
    end
  end
end
