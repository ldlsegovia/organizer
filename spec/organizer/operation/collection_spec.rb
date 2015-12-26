require 'spec_helper'

describe Organizer::Operation::Collection do
  describe "#add_simple_item" do
    it "adds new operation" do
      expect { subject.add_simple_item(:result_attr) {} }.to change { subject.count }.from(0).to(1)
    end

    it "returns a new operation" do
      operation = subject.add_simple_item(:result_attr) {}
      expect(operation).to be_a(Organizer::Operation::Item)
    end
  end

  describe "#add_mask_item" do
    it "adds new operation" do
      expect { subject.add_mask_item(:attr, :upcase) {} }.to change { subject.count }.from(0).to(1)
    end

    it "returns a new operation" do
      operation = subject.add_mask_item(:attr, :upcase) {}
      expect(operation).to be_a(Organizer::Operation::Item)
    end
  end

  describe "#add_group_parent_item" do
    it "adds new group operation" do
      expect { subject.add_group_parent_item(:result_attr, :my_group) {} }.to change { subject.count }.from(0).to(1)
    end

    it "returns a new group operation" do
      operation = subject.add_group_parent_item(:result_attr, :my_group) {}
      expect(operation).to be_a(Organizer::Group::Operation::ParentItem)
    end
  end

  describe "collection mixin" do
    let!(:collection) { Organizer::Operation::Collection.new }
    let!(:collection_exception_class) { Organizer::Operation::CollectionException }

    context "with source item operations" do
      let!(:item) { Organizer::Operation::Item.new(-> {}, :item_name) }
      it_should_behave_like(:collection)
    end

    context "with group item operations" do
      let!(:item) { Organizer::Group::Operation::ParentItem.new(-> {}, :item_name, :my_group) }
      it_should_behave_like(:collection)
    end
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Operation::Collection.new }
    it_should_behave_like(:explainer)
  end
end
