module Organizer::Template
  include Organizer::Error

  # Creates a class that inherits from Organizer::Base and executes the methods inside block.
  # If you pass :my_organizer as _organizer_name param, you will get a MyOrganizer < Organizer::Base class
  #
  # @param _organizer_name [String] the name of the new Organizer::Base child class
  # @yield you can pass methods that will be executed in the new Organizer::Base child class context.
  #   These methods are: {Organizer::Base.collection}
  # @return [void]
  # @raise [Organizer::Exception] :invalid_organizer_name
  #
  # @example Passing a collection
  #   Organizer::Template.define("my_organizer") do
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
  #   #=> Organizer::Base
  def self.define(_organizer_name, &block)
    klass = create_organizer_class(_organizer_name)
    klass.class_eval(&block)
    return
  end

  def self.create_organizer_class(_organizer_name)
    class_name = _organizer_name.to_s.classify
    Object.const_set(class_name, Class.new(Organizer::Base))

  rescue
    raise_error(:invalid_organizer_name)
  end
end
