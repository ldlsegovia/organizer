module Organizer
  module Limit
    module Builder
      include Organizer::Error

      def build_limit_item(_limit_method)
        return if _limit_method.blank?
        limit = _limit_method.args.first
        Organizer::Limit::Item.new(:collection_limit, limit)
      end
    end
  end
end
