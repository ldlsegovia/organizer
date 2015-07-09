require 'spec_helper'

describe Organizer::Source::Item do
  it_should_behave_like(:attributes_handler, Organizer::Source::Item, Organizer::Source::ItemException)
end
