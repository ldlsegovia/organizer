require "organizer/exception"

module Organizer::Error

  def raise_error(_key)
    raise Organizer::Exception.new(Organizer::Exception::ERRORS[_key])
  end

end
