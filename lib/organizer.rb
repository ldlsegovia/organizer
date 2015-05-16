require "organizer/version"
require "organizer/error"
require "organizer/organizer_base"
require "organizer/organized_collection"
require "organizer/organized_item"
require "active_support/all"

module Organizer
  include Error

  def self.define(_organizer_name, &block)
    klass = create_organizer_class(_organizer_name)
    klass.class_eval(&block)
  end

  private

  def self.create_organizer_class(_organizer_name)
    class_name = _organizer_name.to_s.classify
    Object.const_set(class_name, Class.new(OrganizerBase))

  rescue
    raise_error(:invalid_organizer_name)
  end

end
