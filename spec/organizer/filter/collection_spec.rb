require 'spec_helper'

describe Organizer::Filter::Collection do
  describe "collection mixin" do
    let!(:collection) { Organizer::Filter::Collection.new }
    let!(:collection_exception_class) { Organizer::Filter::CollectionException }
    let!(:item) { Organizer::Filter::Item.new(->{}, :item_name) }

    it_should_behave_like(:collection)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Filter::Collection.new }
    it_should_behave_like(:explainer)
  end

  describe "#add_default_filter" do
    it "adds a new default filter" do
      expect { subject.add_default_filter(:my_filter) {} }.to change {
        subject.count }.from(0).to(1)
    end

    it "returns a new default filter" do
      filter = subject.add_default_filter(:my_filter) {}
      expect(filter).to be_a(Organizer::Filter::Item)
      expect(filter.item_name).to eq(:my_filter)
      expect(filter.accept_value).to be_falsy
    end

    it "adds default filter without a name" do
      expect { subject.add_default_filter(nil, &->{}) }.to change { subject.count }.from(0).to(1)
    end
  end

  describe "#add_normal_filter" do
    it "adds a new default filter" do
      expect { subject.add_normal_filter(:my_filter) {} }.to change { subject.count }.from(0).to(1)
    end

    it "returns the new filter" do
      filter = subject.add_normal_filter(:my_filter) {}
      expect(filter).to be_a(Organizer::Filter::Item)
      expect(filter.item_name).to eq(:my_filter)
      expect(filter.accept_value).to be_falsy
    end
  end

  describe "#Organizer::Filter::Applier" do
    it "adds a new default filter" do
      expect { subject.add_filter_with_value(:my_filter) {} }.to change { subject.count }.from(0).to(1)
    end

    it "returns a new default filter" do
      filter = subject.add_default_filter(:my_filter) {}
      expect(filter).to be_a(Organizer::Filter::Item)
      expect(filter.item_name).to eq(:my_filter)
      expect(filter.accept_value).to be_falsy
    end
  end
end
