require 'spec_helper'

describe Organizer::Item do
  it_should_behave_like(:attributes_handler, Organizer::Item, Organizer::ItemException)
end
