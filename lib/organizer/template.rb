module Organizer::Template
  include Organizer::Error

  # Creates a class that inherits from {Organizer::Base} and executes the methods inside the block,
  #  in the inherited class context, in order to customize the new Organizer class behaviour.
  #
  # @param _organizer_name [String] the name of the new {Organizer::Base} inherited class.
  # @yield you can pass methods that will be executed in the new {Organizer::Base} child class context.
  #   These methods are: {Organizer::Base.collection}, {Organizer::Base.default_filter},
  #   {Organizer::Base.filter} and {Organizer::Base.operation}
  # @return [void]
  #
  # @raise [Organizer::TemplateException] :invalid_organizer_name
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
