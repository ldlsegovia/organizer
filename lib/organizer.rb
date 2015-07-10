require "active_support/all"

require "organizer/version"
require "organizer/support"
require "organizer/source"
require "organizer/filter"
require "organizer/operation"
require "organizer/group"
require "organizer/main"

module Organizer
  include Organizer::Error

  # Creates a new Organizer class with behaviour defined on definition block.
  #
  # @param _organizer_name [String] the name of the new {Organizer::Base} inherited class.
  # @yield you need to pass {Organizer::DSL} instance methods inside the block.
  # @return [void]
  def self.define(_organizer_name, &block)
    Organizer::DSL.new(_organizer_name, &block)
    return
  end
end
