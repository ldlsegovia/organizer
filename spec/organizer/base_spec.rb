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
      before { BaseChild.add_collection { valid_raw_collection } }

      it "returns defined collection" do
        result = BaseChild.new.organize
        expect(result).to be_a(Organizer::Collection)
        expect(result.size).to eq(3)
      end

      context "with default filters" do
        before do
          BaseChild.add_default_filter { |item| item.attr1 > 4 }
          BaseChild.add_default_filter(:my_filter) { |item| item.attr1 < 80 }
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
          BaseChild.add_filter(:filter1) { |item| item.attr1 > 4 }
          BaseChild.add_filter(:filter2) { |item| item.attr1 < 80 }
        end

        it "applies filters" do
          result = BaseChild.new.organize(enabled_filters: [:filter1, :filter2])
          expect(result).to be_a(Organizer::Collection)
          expect(result.size).to eq(1)
        end
      end

      context "with filters with values" do
        before do
          BaseChild.add_filter(:filter1, true) { |item, value| item.attr1 > value }
          BaseChild.add_filter(:filter2, true) { |item, value| item.attr1 < value }
        end

        it "applies filters" do
          result = BaseChild.new.organize(filters: { filter1: 4, filter2: 80 })
          expect(result).to be_a(Organizer::Collection)
          expect(result.size).to eq(1)
        end
      end

      context "with autogenerated filters" do
        it "applies filters" do
          result = BaseChild.new.organize(filters: { attr1_eq: 4 })
          expect(result).to be_a(Organizer::Collection)
          expect(result.first.attr1).to eq(4)
          result = BaseChild.new.organize(filters: { attr2_contains: "ia" })
          expect(result.first.attr2).to eq("Ciao")
        end
      end

      context "with operations" do
        before do
          BaseChild.add_operation(:new_attr) { |item| item.attr1 * 2 }
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
    it "uses filters passed as in initialize" do
      BaseChild.add_collection do |options|
        valid_raw_collection.select { |item| item[:attr1] > options[:attr1] }
      end

      expect(BaseChild.new(attr1: 6).collection.count).to eq(1)
    end

    it "raises error with undefined collection" do
      expect { BaseChild.new.collection }.to(
        raise_organizer_error(Organizer::Exception, :undefined_collection_method))
    end

    it "returns an Organizer::Collection instance" do
      BaseChild.add_collection { valid_raw_collection }
      collection = BaseChild.new.collection
      expect(collection).to be_a(Organizer::Collection)
      expect(collection.count).to eq(3)
    end
  end

  describe "#default_filter" do
    it "adds new filter" do
      obj = BaseChild.add_default_filter(:my_filter) {}
      expect(obj).to be_a(Organizer::Filter)
    end

    context "with another child class" do
      before do
        Object.send(:remove_const, :AhotherChild) rescue nil
        class AhotherChild < Organizer::Base; end
      end

      it "adds filter to each class" do
        expect(BaseChild.add_default_filter(:my_filter) {}).to be_a(Organizer::Filter)
        expect(AhotherChild.add_default_filter(:my_filter) {}).to be_a(Organizer::Filter)
      end
    end
  end

  describe "#filter" do
    it "adds new filter" do
      obj = BaseChild.add_filter(:my_filter) {}
      expect(obj).to be_a(Organizer::Filter)
    end

    context "with another child class" do
      before do
        Object.send(:remove_const, :AhotherChild) rescue nil
        class AhotherChild < Organizer::Base; end
      end

      it "adds filter to each class" do
        expect(BaseChild.add_filter(:my_filter) {}).to be_a(Organizer::Filter)
        expect(AhotherChild.add_filter(:my_filter) {}).to be_a(Organizer::Filter)
      end
    end
  end

  describe "#operation" do
    it "adds new operation" do
      obj = BaseChild.add_operation(:my_operation) {}
      expect(obj).to be_a(Organizer::Operation)
    end

    context "with another child class" do
      before do
        Object.send(:remove_const, :AhotherChild) rescue nil
        class AhotherChild < Organizer::Base; end
      end

      it "adds filter to each class" do
        expect(BaseChild.add_operation(:my_operation) {}).to be_a(Organizer::Operation)
        expect(AhotherChild.add_operation(:my_operation) {}).to be_a(Organizer::Operation)
      end
    end
  end
end
