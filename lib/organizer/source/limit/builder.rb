module Organizer
  module Source
    module Limit
      module Builder
        include Organizer::Error

        def self.build(_limit_method)
          return if _limit_method.blank?
          limit = _limit_method.args.first
          Organizer::Limit::Item.new(:collection_limit, limit)
        end
      end
    end
  end
end
