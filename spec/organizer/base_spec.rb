require 'spec_helper'

describe Organizer::Base do
  let_raw_collection(:valid_raw_collection)

  before do
    Object.send(:remove_const, :BaseChild) rescue nil
    class BaseChild < Organizer::Base; end
  end

  describe "#organize" do
    context "without defined collection" do
      it "raises error with undefined collection" do
        expect { BaseChild.new.organize }.to(
          raise_organizer_error(Organizer::Exception, :undefined_collection_method))
      end
    end

    context "with defined collection" do
      before { BaseChild.collection { valid_raw_collection } }

      it "returns defined collection" do
        result = BaseChild.new.organize
        expect(result).to be_a(Organizer::Collection)
        expect(result.size).to eq(3)
      end

      context "with default filters" do
        before do
          BaseChild.default_filter { |item| item.attr1 > 4 }
          BaseChild.default_filter(:my_filter) { |item| item.attr1 < 80 }
        end

        it "returns filtered collection" do
          result = BaseChild.new.organize
          expect(result).to be_a(Organizer::Collection)
          expect(result.size).to eq(1)
        end

        it "skips default filter passing filter to skip_default_filter option" do
          result = BaseChild.new.organize({ skip_default_filters: [:my_filter] })
          expect(result).to be_a(Organizer::Collection)
          expect(result.size).to eq(2)
        end
      end

      context "with normal filters" do
        before do
          BaseChild.filter(:filter1) { |item| item.attr1 > 4 }
          BaseChild.filter(:filter2) { |item| item.attr1 < 80 }
        end

        it "applies filters" do
          result = BaseChild.new.organize(enabled_filters: [:filter1, :filter2])
          expect(result).to be_a(Organizer::Collection)
          expect(result.size).to eq(1)
        end
      end

      context "with filters with values" do
        before do
          BaseChild.filter(:filter1, true) { |item, value| item.attr1 > value }
          BaseChild.filter(:filter2, true) { |item, value| item.attr1 < value }
        end

        it "applies filters" do
          result = BaseChild.new.organize(filters: { filter1: 4, filter2: 80 })
          expect(result).to be_a(Organizer::Collection)
          expect(result.size).to eq(1)
        end
      end

      context "with operations" do
        before do
          BaseChild.operation(:new_attr) { |item| item.attr1 * 2 }
        end

        it "applies filters" do
          base = BaseChild.new
          result = base.organize
          expect(result).to be_a(Organizer::Collection)
          expect(result.first.new_attr).to eq(8)
          expect(result.second.new_attr).to eq(12)
          expect(result.third.new_attr).to eq(168)
        end
      end
    end
  end

  describe "#collection" do
    it "creates the private collection instance method" do
      expect(BaseChild.new.respond_to?(:collection, true)).to be_falsy
      BaseChild.collection { valid_raw_collection }
      expect(BaseChild.new.respond_to?(:collection, true)).to be_truthy
    end

    it "raises error with undefined collection" do
      expect { BaseChild.new.collection }.to(
        raise_organizer_error(Organizer::Exception, :undefined_collection_method))
    end

    it "returns an Organizer::Collection instance" do
      BaseChild.collection { valid_raw_collection }
      collection = BaseChild.new.collection
      expect(collection).to be_a(Organizer::Collection)
      expect(collection.count).to eq(3)
    end
  end

  describe "#default_filter" do
    it "adds new filter" do
      obj = BaseChild.default_filter(:my_filter) {}
      expect(obj).to be_a(Organizer::Filter)
    end

    context "with another child class" do
      before do
        Object.send(:remove_const, :AhotherChild) rescue nil
        class AhotherChild < Organizer::Base; end
      end

      it "adds filter to each class" do
        expect(BaseChild.default_filter(:my_filter) {}).to be_a(Organizer::Filter)
        expect(AhotherChild.default_filter(:my_filter) {}).to be_a(Organizer::Filter)
      end
    end
  end

  describe "#filter" do
    it "adds new filter" do
      obj = BaseChild.filter(:my_filter) {}
      expect(obj).to be_a(Organizer::Filter)
    end

    context "with another child class" do
      before do
        Object.send(:remove_const, :AhotherChild) rescue nil
        class AhotherChild < Organizer::Base; end
      end

      it "adds filter to each class" do
        expect(BaseChild.filter(:my_filter) {}).to be_a(Organizer::Filter)
        expect(AhotherChild.filter(:my_filter) {}).to be_a(Organizer::Filter)
      end
    end
  end

  describe "#operation" do
    it "adds new operation" do
      obj = BaseChild.operation(:my_operation) {}
      expect(obj).to be_a(Organizer::Operation)
    end

    context "with another child class" do
      before do
        Object.send(:remove_const, :AhotherChild) rescue nil
        class AhotherChild < Organizer::Base; end
      end

      it "adds filter to each class" do
        expect(BaseChild.operation(:my_operation) {}).to be_a(Organizer::Operation)
        expect(AhotherChild.operation(:my_operation) {}).to be_a(Organizer::Operation)
      end
    end
  end
end
