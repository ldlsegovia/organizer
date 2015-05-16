require 'spec_helper'

describe OrganizerBase do

  describe "#collection" do

    before do
      Object.send(:remove_const, :BaseChild) rescue nil
      class BaseChild < OrganizerBase; end
    end

    let(:valid_raw_collection) do
      [{ attr1: "value1" }, { attr1: "value2" }]
    end

    it "creates the private collection instance method" do
      expect(BaseChild.new.respond_to?(:collection, true)).to be_falsy
      BaseChild.collection { valid_raw_collection }
      expect(BaseChild.new.respond_to?(:collection, true)).to be_truthy
    end

    it "raises error with undefined collection" do
      expect { BaseChild.new.send(:collection) }.to(
        raise_organizer_error(:undefined_collection_method))
    end

    it "raises error when collection method does not return an Array" do
      BaseChild.collection { "I'm not an array" }
      expect { BaseChild.new.send(:collection) }.to(
        raise_organizer_error(:invalid_collection_structure))
    end

    it "raises error with collection method not returning a Array of Hashes" do
      BaseChild.collection { ["I'm not a hash"] }
      expect { BaseChild.new.send(:collection) }.to(
        raise_organizer_error(:invalid_collection_item_structure))
    end

    it "returns an OrganizedCollection instance" do
      BaseChild.collection { valid_raw_collection }
      collection = BaseChild.new.send(:collection)
      expect(collection).to be_a(OrganizedCollection)
      expect(collection.count).to eq(2)
    end

  end

end
