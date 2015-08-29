module Organizer
  module Filter
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Filter::Item

      # Creates a new {Organizer::Filter::Item} and adds to default filters collection.
      #
      # @param _name [optional, Symbol] filter's name. Not mandatory for default filters.
      # @yield code that must return a Boolean value.
      # @yieldparam organizer_item [Organizer::Source::Item] you can use item's attributes in your conditions.
      # @yieldreturn [Boolean]
      # @return [Organizer::Filter::Item]
      def add_default_filter(_name = nil, &block)
        add_normal_filter(_name, &block)
      end

      # Creates a new {Organizer::Filter::Item} and adds to normal filters collection.
      #
      # @param _name [Symbol] filter's name.
      # @yield code that must return a Boolean value.
      # @yieldparam organizer_item [Organizer::Source::Item] you can use item's attributes in your conditions.
      # @yieldreturn [Boolean]
      # @return [Organizer::Filter::Item]
      def add_normal_filter(_name, &block)
        self << Organizer::Filter::Item.new(block, _name)
        self.last
      end

      # Creates a new {Organizer::Filter::Item} (with true accept_value) and adds to filters with values collection.
      #
      # @param _name [Symbol] filter's name.
      # @yield  code that must return a Boolean value.
      # @yieldparam organizer_item [Organizer::Source::Item] you can use item's attributes in your conditions.
      # @yieldparam value [Object] you can use this value in your conditions. Can be anything.
      # @yieldreturn [Boolean]
      # @return [Organizer::Filter::Item]
      def add_filter_with_value(_name, &block)
        self << Organizer::Filter::Item.new(block, _name, true)
        self.last
      end
    end
  end
end
