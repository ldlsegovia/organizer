require "active_support/all"
require "colorize"

require "organizer/version"

require_relative "organizer/mixin/error"
require_relative "organizer/mixin/attributes_handler"
require_relative "organizer/mixin/collection"
require_relative "organizer/mixin/collection_item"
require_relative "organizer/mixin/explainer"

require_relative "organizer/source/item"
require_relative "organizer/source/collection"

require_relative "organizer/filter/applier"
require_relative "organizer/filter/item"
require_relative "organizer/filter/collection"
require_relative "organizer/filter/generator"

require_relative "organizer/operation/item"
require_relative "organizer/operation/simple"
require_relative "organizer/operation/memo"
require_relative "organizer/operation/collection"
require_relative "organizer/operation/executor"

require_relative "organizer/group/item"
require_relative "organizer/group/collection"
require_relative "organizer/group/builder"

require_relative "organizer/main/context_manager"
require_relative "organizer/main/dsl"
require_relative "organizer/main/executor"
require_relative "organizer/main/base"

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
