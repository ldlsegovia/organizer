require 'spec_helper'

describe Organizer::Group::Collection do
  describe "collection mixin" do
    let!(:collection) { Organizer::Group::Collection.new }
    let!(:collection_exception_class) { Organizer::Group::CollectionException }
    let!(:item) { Organizer::Group::Item.new(:item_name) }

    it_should_behave_like(:collection)
  end
end
