module Organizer
  module Filter
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Filter::Item

      # Creates a new {Organizer::Filter::Item} and adds to collection (self)
      #
      # @param _name [optional, Symbol] filter's name. Can be nil for default filters
      # @yield code that must return a Boolean value.
      # @yieldparam organizer_item [Organizer::Source::Item] to build your conditions.
      # @yieldparam value [optional, Object] to use in your conditions. Can be anything.
      # @yieldreturn [Boolean]
      # @return [Organizer::Filter::Item]
      def add_filter(_name = nil, &block)
        self << Organizer::Filter::Item.new(block, _name)
        last
      end
    end
  end
end
