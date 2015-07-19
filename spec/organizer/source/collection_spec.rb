require 'spec_helper'

describe Organizer::Source::Collection do
  let_collection(:collection)

  describe "collection mixin" do
    let!(:collection) { Organizer::Source::Collection.new }
    let!(:collection_exception_class) { Organizer::Source::CollectionException }

    let!(:item) do
      source_item = Organizer::Source::Item.new
      source_item.instance_variable_set(:@name, :item_name)
      source_item
    end

    it_should_behave_like(:collection)
  end

  describe "#fill" do
    it "raises error when collection method does not return an Array" do
      expect { Organizer::Source::Collection.new.fill("I'm not an array" ) }.to(
        raise_organizer_error(Organizer::Source::CollectionException, :invalid_collection_structure))
    end

    it "raises error with collection method not returning a Array of Hashes" do
      expect { Organizer::Source::Collection.new.fill(["I'm not a hash"]) }.to(
        raise_organizer_error(Organizer::Source::CollectionException, :invalid_collection_item_structure))
    end

    it "returns an Organizer::Source::Collection instance" do
      collection = Organizer::Source::Collection.new.fill(raw_collection)
      expect(collection).to be_a(Organizer::Source::Collection)
      expect(collection.count).to eq(9)
    end
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Source::Collection.new.fill(raw_collection) }
    it_should_behave_like(:explainer)
  end
end
