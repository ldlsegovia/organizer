require 'spec_helper'

describe Organizer::Filter::Collection do
  describe "collection mixin" do
    let!(:collection) { Organizer::Filter::Collection.new }
    let!(:collection_exception_class) { Organizer::Filter::CollectionException }
    let!(:item) { Organizer::Filter::Item.new(Proc.new {}, :item_name) }

    it_should_behave_like(:collection)
  end
end
