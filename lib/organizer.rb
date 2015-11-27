require "require_all"
require "active_support/all"
require "colorize"

require_all "lib"

module Organizer
  include Organizer::Error

  def self.define(_organizer_name, &block)
    Organizer::DSL.new(_organizer_name, &block)
    nil
  end
end
