module Organizer
  module Source
    module Limit
      module Builder
        include Organizer::Error
        extend Organizer::Limit::Builder

        def self.build(_limit_method)
          build_limit_item(_limit_method)
        end
      end
    end
  end
end
