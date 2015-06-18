require 'spec_helper'

describe Organizer::GroupItem do
  it_should_behave_like(:attributes_handler, Organizer::GroupItem, Organizer::GroupItemException)
end
