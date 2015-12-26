require 'spec_helper'

describe Organizer::Sort::Collection do
  describe "collection mixin" do
    let!(:collection) { Organizer::Sort::Collection.new }
    let!(:collection_exception_class) { Organizer::Sort::CollectionException }
    let!(:item) { Organizer::Sort::Item.new(:item_name) }

    it_should_behave_like(:collection)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Sort::Collection.new }
    it_should_behave_like(:explainer)
  end

  describe "#add" do
    it "adds a new item" do
      expect { subject.add(:item_name) }.to change { subject.count }.from(0).to(1)
    end

    it "returns the new sort item" do
      item = subject.add(:item_name)
      expect(item).to be_a(Organizer::Sort::Item)
      expect(item.item_name).to eq(:item_name)
      expect(item.descending).to be_falsey
    end
  end
end
