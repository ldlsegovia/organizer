require 'spec_helper'

describe Organizer::Operation::Collection do
  describe "collection mixin" do
    let!(:collection) { Organizer::Operation::Collection.new }
    let!(:collection_exception_class) { Organizer::Operation::CollectionException }

    context "with source item operations" do
      let!(:item) do
        proc = Proc.new {}
        operation = Organizer::Operation::SourceItem.new(proc, :item_name)
        operation
      end

      it_should_behave_like(:collection)
    end

    context "with group item operations" do
      let!(:item) do
        proc = Proc.new {}
        operation = Organizer::Operation::GroupItem.new(proc, :item_name, :my_group)
        operation
      end

      it_should_behave_like(:collection)
    end
  end
end
