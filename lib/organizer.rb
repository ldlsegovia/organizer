require "organizer/version"
require "organizer/error"
require "active_support/all"

module Organizer
  extend Error

  def self.define(_organize_name)
    klass = create_organizer_class(_organize_name)
  end

  private

  def self.create_organizer_class(_organize_name)
    class_name = _organize_name.to_s.classify
    self.const_set(class_name, Class.new)

  rescue
    raise_error(:invalid_organizer_name)
  end

end
