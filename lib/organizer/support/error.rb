module Organizer
  module Error
    def self.included(_base)
      _base.extend(ClassMethods)
    end

    def raise_error(_key)
      self.class.raise_error(_key)
    end

    module ClassMethods
      def raise_error(_msg)
        error_class = eval("#{self}Exception") rescue nil
        error_class = Organizer::Exception unless error_class
        error_msg = error_class::ERRORS[_msg] || _msg
        raise error_class.new(error_msg)
      end
    end
  end
end
