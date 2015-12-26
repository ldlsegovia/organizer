require 'spec_helper'

describe Organizer::Operation::Collection do
  describe "#add" do
    it "adds new operation" do
      expect { subject.add(:result_attr) {} }.to change { subject.count }.from(0).to(1)
    end

    it "returns a new operation" do
      operation = subject.add(:result_attr) {}
      expect(operation).to be_a(Organizer::Operation::Item)
    end
  end

  describe "collection mixin" do
    let!(:collection) { Organizer::Operation::Collection.new }
    let!(:collection_exception_class) { Organizer::Operation::CollectionException }
    let!(:item) { Organizer::Operation::Item.new(-> {}, :item_name) }

    it_should_behave_like(:collection)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Operation::Collection.new }
    it_should_behave_like(:explainer)
  end
end
