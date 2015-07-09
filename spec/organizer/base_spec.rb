require 'spec_helper'

describe Organizer::Base do
  let_collection(:collection)

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
      before { BaseChild.add_collection { raw_collection } }

      it "returns defined collection" do
        result = BaseChild.new.organize
        expect(result).to be_a(Organizer::Collection)
        expect(result.size).to eq(9)
      end

      context "with default filters" do
        before do
          BaseChild.add_default_filter { |item| item.age > 9 }
          BaseChild.add_default_filter(:my_filter) { |item| item.age < 33 }
        end

        it "returns filtered collection" do
          result = BaseChild.new.organize
          expect(result).to be_a(Organizer::Collection)
          expect(result.size).to eq(3)
        end

        it "skips default filter passing filter to skip_default_filter option" do
          result = BaseChild.new.organize({ skip_default_filters: [:my_filter] })
          expect(result).to be_a(Organizer::Collection)
          expect(result.size).to eq(8)
        end
      end

      context "with normal filters" do
        before do
          BaseChild.add_filter(:filter1) { |item| item.age > 9 }
          BaseChild.add_filter(:filter2) { |item| item.age < 33 }
        end

        it "applies filters" do
          result = BaseChild.new.organize(enabled_filters: [:filter1, :filter2])
          expect(result).to be_a(Organizer::Collection)
          expect(result.size).to eq(3)
        end
      end

      context "with filters with values" do
        before do
          BaseChild.add_filter_with_value(:filter1) { |item, value| item.age > value }
          BaseChild.add_filter_with_value(:filter2) { |item, value| item.age < value }
        end

        it "applies filters" do
          result = BaseChild.new.organize(filters: { filter1: 9, filter2: 33 })
          expect(result).to be_a(Organizer::Collection)
          expect(result.size).to eq(3)
        end
      end

      context "with autogenerated filters" do
        it "applies filters" do
          result = BaseChild.new.organize(filters: { age_eq: 8 })
          expect(result).to be_a(Organizer::Collection)
          expect(result.first.name).to eq("Francisco")
          result = BaseChild.new.organize(filters: { name_contains: "Manu" })
          expect(result.first.name).to eq("Juan Manuel")
        end
      end

      context "with operations" do
        before { BaseChild.add_operation(:new_attr) { |item| item.age * 2 } }

        it "executes operations" do
          base = BaseChild.new
          result = base.organize
          expect(result).to be_a(Organizer::Collection)
          expect(result.first.new_attr).to eq(44)
          expect(result.second.new_attr).to eq(62)
          expect(result.third.new_attr).to eq(128)
        end
      end

      context "with groups" do
        before { BaseChild.add_group(:site_id) }

        it "groups collection items" do
          base = BaseChild.new
          result = base.organize(group_by: :site_id)
          expect(result).to be_a(Organizer::Group)
          expect(result.size).to eq(3)
        end

        context "with operations" do
          before do
            BaseChild.add_group_operation(:attrs_sum, :site_id, 10) do |group_item, item|
              group_item.attrs_sum += item.age
            end
          end

          it "groups collection items" do
            base = BaseChild.new
            result = base.organize(group_by: :site_id)
            expect(result.first.size).to eq(2)
            expect(result.first.attrs_sum).to eq(10 + result.first.age + result.last.age)
          end
        end
      end
    end
  end

  describe "#add_collection" do
    it "uses filters passed on initialize" do
      BaseChild.add_collection do |options|
        raw_collection.select { |item| item[:age] < options[:age] }
      end

      expect(BaseChild.new(age: 9).collection.count).to eq(1)
    end

    it "raises error with undefined collection" do
      expect { BaseChild.new.collection }.to(
        raise_organizer_error(Organizer::Exception, :undefined_collection_method))
    end

    it "returns an Organizer::Collection instance" do
      BaseChild.add_collection { raw_collection }
      collection = BaseChild.new.collection
      expect(collection).to be_a(Organizer::Collection)
      expect(collection.count).to eq(9)
    end
  end

  describe "#add_default_filter" do
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

  describe "#add_filter" do
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

  describe "#add_operation" do
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

  describe "#add_group_operation" do
    it "adds new operation" do
      obj = BaseChild.add_group_operation(:my_operation, :my_group) {}
      expect(obj).to be_a(Organizer::Operation)
    end

    context "with another child class" do
      before do
        Object.send(:remove_const, :AhotherChild) rescue nil
        class AhotherChild < Organizer::Base; end
      end

      it "adds filter to each class" do
        expect(BaseChild.add_group_operation(:my_operation, :my_group) {}).to be_a(Organizer::Operation)
        expect(AhotherChild.add_group_operation(:my_operation, :my_group) {}).to be_a(Organizer::Operation)
      end
    end
  end
end
