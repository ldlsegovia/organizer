require 'rspec/expectations'

RSpec::Matchers.define :raise_organizer_error do |error_key|
  match do |operation|
    begin
      operation.call
      return false

    rescue Organizer::Exception => e
      return e.message == Organizer::Exception::ERRORS[error_key]
    end
  end

  failure_message do |operation|
    "expected Organizer::Exception with :#{error_key} error key, but nothing was raised"
  end

  def supports_block_expectations?
    true
  end
end
