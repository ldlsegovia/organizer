Pry.config.print = proc do |output, value, _pry_|
  if value.class.included_modules.include?(::Organizer::Explainer)
    output.puts "#{value.inspect}"
  else
    ::Pry::DEFAULT_PRINT.call(output, value, _pry_)
  end
end
