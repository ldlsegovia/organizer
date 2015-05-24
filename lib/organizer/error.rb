module Organizer::Error

  def self.included(_base)
    _base.extend(ClassMethods)
  end

  def raise_error(_key)
    self.class.raise_error(_key)
  end

  module ClassMethods
    def raise_error(_key)
      error_class = eval("#{self}Exception") rescue nil
      error_class = Organizer::Exception unless error_class
      raise error_class.new(error_class::ERRORS[_key])
    end
  end

end
