require 'spec_helper'

describe Organizer::Limit::Collection do
  describe "collection mixin" do
    let!(:collection) { Organizer::Limit::Collection.new }
    let!(:collection_exception_class) { Organizer::Limit::CollectionException }
    let!(:item) { Organizer::Limit::Item.new(:item_name, 10) }

    it_should_behave_like(:collection)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Limit::Collection.new }
    it_should_behave_like(:explainer)
  end

  describe "#add" do
    it "adds a new item" do
      expect { subject.add(:item_name, 10) }.to change { subject.count }.from(0).to(1)
    end

    it "returns the new sort item" do
      item = subject.add(:item_name, 10)
      expect(item).to be_a(Organizer::Limit::Item)
      expect(item.item_name).to eq(:item_name)
      expect(item.value).to eq(10)
    end
  end
end
