require "organizer/exception"

module Organizer::Error

  def self.included(_base)
    _base.extend(ClassMethods)
  end

  def raise_error(_key)
    self.class.raise_error(_key)
  end

  module ClassMethods
    def raise_error(_key)
      raise Organizer::Exception.new(Organizer::Exception::ERRORS[_key])
    end
  end

end
