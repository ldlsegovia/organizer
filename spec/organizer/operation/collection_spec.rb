require 'spec_helper'

describe Organizer::Operation::Collection do
  describe "collection mixin" do
    let!(:collection) { Organizer::Operation::Collection.new }
    let!(:collection_exception_class) { Organizer::Operation::CollectionException }

    context "with source item operations" do
      let!(:item) { Organizer::Operation::SourceItem.new(->{}, :item_name) }
      it_should_behave_like(:collection)
    end

    context "with group item operations" do
      let!(:item) { Organizer::Operation::Memo.new(->{}, :item_name, :my_group) }
      it_should_behave_like(:collection)
    end
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Operation::Collection.new }
    it_should_behave_like(:explainer)
  end
end
