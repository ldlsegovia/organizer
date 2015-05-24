require 'spec_helper'

describe Organizer::Base do
  before do
    Object.send(:remove_const, :BaseChild) rescue nil
    class BaseChild < Organizer::Base; end
  end

  describe "#collection" do
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
        raise_organizer_error(Organizer::Exception, :undefined_collection_method))
    end

    it "raises error when collection method does not return an Array" do
      BaseChild.collection { "I'm not an array" }
      expect { BaseChild.new.send(:collection) }.to(
        raise_organizer_error(Organizer::Exception, :invalid_collection_structure))
    end

    it "raises error with collection method not returning a Array of Hashes" do
      BaseChild.collection { ["I'm not a hash"] }
      expect { BaseChild.new.send(:collection) }.to(
        raise_organizer_error(Organizer::Exception, :invalid_collection_item_structure))
    end

    it "returns an Organizer::Collection instance" do
      BaseChild.collection { valid_raw_collection }
      collection = BaseChild.new.send(:collection)
      expect(collection).to be_a(Organizer::Collection)
      expect(collection.count).to eq(2)
    end
  end

  shared_examples :definitions_collection do |_definition_method, _definition_collection, _error_class|
    it "adds new object with definition to collection" do
      expect(BaseChild.send(_definition_collection).size).to eq(0)
      BaseChild.send(_definition_method, :name) do
        # content is no important right here.
      end
      expect(BaseChild.send(_definition_collection).size).to eq(1)
      BaseChild.send(_definition_method, :name) do
        # content is no important right here.
      end
      expect(BaseChild.send(_definition_collection).size).to eq(2)
    end

    it "raises error without block" do
      expect { BaseChild.send(_definition_method, :name) }.to(
        raise_organizer_error(_error_class, :definition_must_be_a_proc))
    end

    context "with another child class" do
      before do
        Object.send(:remove_const, :AhotherChild) rescue nil
        class AhotherChild < Organizer::Base; end
      end

      it "adds object with definition to each class collections " do
        expect(BaseChild.send(_definition_collection).size).to eq(0)
        expect(AhotherChild.send(_definition_collection).size).to eq(0)
        BaseChild.send(_definition_method, :name) do
          # content is no important right here.
        end
        expect(BaseChild.send(_definition_collection).size).to eq(1)
        expect(AhotherChild.send(_definition_collection).size).to eq(0)
        AhotherChild.send(_definition_method, :name) do
          # content is no important right here.
        end
        expect(BaseChild.send(_definition_collection).size).to eq(1)
        expect(AhotherChild.send(_definition_collection).size).to eq(1)
      end
    end
  end

  describe "#default_filter" do
    it_should_behave_like(:definitions_collection,
      :default_filter, :default_filters, Organizer::FilterException)

    it "adds default filter without a name" do
      BaseChild.default_filter do
        # content is no important right here.
      end
      expect(BaseChild.default_filters.size).to eq(1)
    end
  end

  describe "#filter" do
    it_should_behave_like(:definitions_collection,
      :filter, :filters, Organizer::FilterException)
  end

  describe "#operation" do
    it_should_behave_like(:definitions_collection,
      :operation, :operations, Organizer::OperationException)
  end
end
