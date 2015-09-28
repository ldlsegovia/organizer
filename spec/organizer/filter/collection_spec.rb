require 'spec_helper'

describe Organizer::Filter::Collection do
  describe "collection mixin" do
    let!(:collection) { Organizer::Filter::Collection.new }
    let!(:collection_exception_class) { Organizer::Filter::CollectionException }
    let!(:item) { Organizer::Filter::Item.new(-> {}, :item_name) }

    it_should_behave_like(:collection)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Filter::Collection.new }
    it_should_behave_like(:explainer)
  end

  describe "#add_filter" do
    it "adds a new filter" do
      expect { subject.add_filter(:my_filter) {} }.to change { subject.count }.from(0).to(1)
    end

    it "returns the new filter" do
      filter = subject.add_filter(:my_filter) {}
      expect(filter).to be_a(Organizer::Filter::Item)
      expect(filter.item_name).to eq(:my_filter)
    end

    it "adds filter without a name" do
      expect { subject.add_filter(nil, &->{}) }.to change { subject.count }.from(0).to(1)
    end
  end
end
