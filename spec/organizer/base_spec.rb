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

  describe "#default_filter" do

    it "adds new filters to filters collection" do
      expect(BaseChild.default_filters).to be_nil
      BaseChild.default_filter do
        # content is no important right here.
      end
      expect(BaseChild.default_filters.size).to eq(1)
      BaseChild.default_filter do
        # content is no important right here.
      end
      expect(BaseChild.default_filters.size).to eq(2)
    end

    it "raises error without block" do
      expect { BaseChild.default_filter() }.to(
        raise_organizer_error(Organizer::FilterException, :definition_must_be_a_proc))
    end

    context "with another Child class" do

      before do
        Object.send(:remove_const, :AhotherChild) rescue nil
        class AhotherChild < Organizer::Base; end
      end

      it "defines default filters for each class" do
        expect(BaseChild.default_filters).to be_nil
        expect(AhotherChild.default_filters).to be_nil
        BaseChild.default_filter do
          # content is no important right here.
        end
        expect(BaseChild.default_filters.size).to eq(1)
        expect(AhotherChild.default_filters).to be_nil
        AhotherChild.default_filter do
          # content is no important right here.
        end
        expect(BaseChild.default_filters.size).to eq(1)
        expect(AhotherChild.default_filters.size).to eq(1)
      end

    end

  end

  describe "#operation" do

    it "adds new operations to operations collection" do
      expect(BaseChild.operations).to be_nil
      BaseChild.operation :my_operation do
        # content is no important right here.
      end
      expect(BaseChild.operations.size).to eq(1)
      BaseChild.operation :other_operation do
        # content is no important right here.
      end
      expect(BaseChild.operations.size).to eq(2)
    end

    it "raises error without block" do
      expect { BaseChild.operation(:my_operation) }.to(
        raise_organizer_error(Organizer::OperationException, :definition_must_be_a_proc))
    end

    context "with another Child class" do

      before do
        Object.send(:remove_const, :AhotherChild) rescue nil
        class AhotherChild < Organizer::Base; end
      end

      it "defines default operations for each class" do
        expect(BaseChild.operations).to be_nil
        expect(AhotherChild.operations).to be_nil
        BaseChild.operation(:my_operation) do
          # content is no important right here.
        end
        expect(BaseChild.operations.size).to eq(1)
        expect(AhotherChild.operations).to be_nil
        AhotherChild.operation(:my_operation) do
          # content is no important right here.
        end
        expect(BaseChild.operations.size).to eq(1)
        expect(AhotherChild.operations.size).to eq(1)
      end

    end

  end

end
