$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
Dir.glob(File.dirname(__FILE__) + "/support/**/*.rb").each {|f| require f}

require 'pry'
require 'organizer'

RSpec.configure do |c|
  c.extend HelpfulVariables
end
