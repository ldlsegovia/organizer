require 'rspec/expectations'

RSpec::Matchers.define :raise_organizer_error do |error_class, error_key|
  match do |operation|
    begin
      operation.call
      return false

    rescue Exception => e
      return e.message == error_class::ERRORS[error_key]
    end
  end

  failure_message do |operation|
    "expected #{error_class} with :#{error_key} error key, but nothing was raised"
  end

  def supports_block_expectations?
    true
  end
end
