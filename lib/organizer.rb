require "organizer/version"
require "organizer/error"
require "organizer/organizer_base"
require "organizer/organized_collection"
require "organizer/organized_item"
require "active_support/all"

module Organizer
  include Error

  # Creates a class that inherits from OrganizerBase and executes the methods inside block.
  # If you pass :my_organizer as _organizer_name param, you will get a MyOrganizer < OrganizerBase class
  #
  # @param _organizer_name [String] the name of the new OrganizerBase child class
  # @yield you can pass methods that will be executed in the new OrganizerBase child class context.
  #   These methods are: {OrganizerBase.collection}
  # @return [void]
  # @raise [Organizer::Exception] :invalid_organizer_name
  #
  # @example Passing a collection
  #   Organizer.define("my_organizer") do
  #     collection do
  #       [
  #         { attr1: 4, attr2: "Hi" },
  #         { attr1: 6, attr2: "Ciao" },
  #         { attr1: 84, attr2: "Hola" }
  #       ]
  #     end
  #   end
  #
  #   MyOrganizer
  #   #=> MyOrganizer
  #   MyOrganizer.superclass
  #   #=> OrganizerBase
  def self.define(_organizer_name, &block)
    klass = create_organizer_class(_organizer_name)
    klass.class_eval(&block)
    return
  end

  private

  def self.create_organizer_class(_organizer_name)
    class_name = _organizer_name.to_s.classify
    Object.const_set(class_name, Class.new(OrganizerBase))

  rescue
    raise_error(:invalid_organizer_name)
  end

end
