module Organizer::Template
  include Organizer::Error

  # Creates a new Organizer class with behaviour defined on definition block.
  #
  # @param _organizer_name [String] the name of the new {Organizer::Base} inherited class.
  # @yield you need to pass {Organizer::DSL} instance methods inside the block.
  # @return [void]
  #
  # @example Passing a collection
  #   Organizer::Template.define("my_organizer") do
  #     collection do |collection_options|
  #       [
  #         { attr1: 4, attr2: "Hi", attr3: 13 },
  #         { attr1: 6, attr2: "Ciao", attr3: 2},
  #         { attr1: 84, attr2: "Hola", attr3: 82 }
  #       ]
  #     end
  #
  #     default_filter do |organizer_item|
  #       organizer_item.attr1 > 5
  #     end
  #
  #     filter(:my_filter) do |organizer_item|
  #       organizer_item.attr3 > 15
  #     end
  #
  #     filter(:other_filter, true) do |organizer_item, value|
  #       organizer_item.attr1 > value
  #     end
  #
  #     operation(:sum_attr) do |organizer_item|
  #       organizer_item.attr1 + organizer_item.attr3
  #     end
  #   end
  #
  #   MyOrganizer
  #   #=> MyOrganizer
  #   MyOrganizer.superclass
  #   #=> Organizer::Base
  def self.define(_organizer_name, &block)
    Organizer::DSL.new(_organizer_name, &block)
    return
  end
end
