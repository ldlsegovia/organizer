require 'spec_helper'

describe Organizer::Filter::Manager do
  let_collection(:collection)

  describe "#add_default_filter" do
    it "adds a new default filter" do
      expect { subject.add_default_filter(:my_filter) {} }.to change {
        subject.send(:default_filters).count }.from(0).to(1)
    end

    it "returns a new default filter" do
      filter = subject.add_default_filter(:my_filter) {}
      expect(filter).to be_a(Organizer::Filter::Item)
    end

    it "adds default filter without a name" do
      proc = Proc.new {}
      expect(subject.send(:default_filters).size).to eq(0)
      subject.add_default_filter(nil, &proc)
      expect(subject.send(:default_filters).size).to eq(1)
    end
  end

  describe "#add_normal_filter" do
    it "adds a new default filter" do
      expect { subject.add_normal_filter(:my_filter) {} }.to change {
        subject.send(:normal_filters).count }.from(0).to(1)
    end

    it "returns a new default filter" do
      filter = subject.add_normal_filter(:my_filter) {}
      expect(filter).to be_a(Organizer::Filter::Item)
    end
  end

  describe "#apply" do
    context "with default filters" do
      before do
        subject.add_default_filter { |item| item.age > 9 }
        subject.add_default_filter(:my_filter) { |item| item.age < 33 }
      end

      it "returns filtered collection" do
        result = subject.apply(collection)
        expect(result.size).to eq(3)
      end

      it "skips default filter passing filter to skip_default_filter option" do
        result = subject.apply(collection, { skip_default_filters: [:my_filter] })
        expect(result.size).to eq(8)
      end

      it "skips all default filters :all key to skip_default_filter option" do
        result = subject.apply(collection, { skip_default_filters: :all })
        expect(result.size).to eq(9)
      end
    end

    context "with normal filters" do
      before do
        subject.add_normal_filter(:filter1) { |item| item.age > 9 }
        subject.add_normal_filter(:filter2) { |item| item.age < 33 }
      end

      it "returns filtered collection" do
        expect(subject.apply(collection).size).to eq(9)
        expect(subject.apply(collection, enabled_filters: [:filter1]).size).to eq(8)
        expect(subject.apply(collection, enabled_filters: [:filter1, :filter2]).size).to eq(3)
      end
    end

    context "with filters with value" do
      before do
        subject.add_filter_with_value(:filter1) { |item, value| item.age > value }
        subject.add_filter_with_value(:filter2) { |item, value| item.age < value }
      end

      it "returns filtered collection" do
        expect(subject.apply(collection).size).to eq(9)
        expect(subject.apply(collection, filters: { filter1: 9 }).size).to eq(8)
        expect(subject.apply(collection, filters: { filter1: 9, filter2: 33 }).size).to eq(3)
      end
    end

    context "with autogenerated filters" do
      it "returns filtered collection" do
        expect(subject.apply(collection, filters: { age_eq: 8 }).size).to eq(1)
        expect(subject.apply(collection, filters: { name_contains: "Manuel" }).size).to eq(1)
      end

      it "avoids filters generation with empty collection" do
         expect(subject.apply(Organizer::Source::Collection.new, filters: { attr1_eq: 4 }).size).to eq(0)
      end
    end
  end

  describe "#generate_usual_filters" do
    let_item(:item)
    let(:collection) { Organizer::Source::Collection.new << item }
    before do
      subject.generate_usual_filters(item)
      @all_filters = subject.send(:all_filters)
    end

    it "raise exception if _item is not an Organizer::Source::Item" do
      expect { subject.generate_usual_filters("not an item") }.to(
        raise_organizer_error(Organizer::Filter::ManagerException, :generate_over_organizer_items_only))
    end

    it "has generated filters" do
      item_hash_keys.each do |attribute|
        [:eq, :not_eq, :gt, :lt, :goet, :loet, :starts, :ends, :contains].each do |sufix|
          filter_name = "#{attribute}_#{sufix}"
          expect(@all_filters.filter_by_name(filter_name).name).to eq(filter_name)
        end
      end
    end

    it "executes attr_eq filters properly" do
      item_hash_keys.each do |attribute|
        filter_name = "#{attribute}_eq"
        params = { filters: { filter_name => item.send(attribute) } }
        expect(subject.apply(collection, params).count).to eq(1)
      end
    end

    it "executes attr_not_eq filters properly" do
      item_hash_keys.each do |attribute|
        filter_name = "#{attribute}_not_eq"
        expect(subject.apply(collection, { filters: { filter_name => 666 } }).count).to eq(1)
        expect(subject.apply(collection, { filters: { filter_name => item.send(attribute) } }).count).to eq(0)
      end
    end

    it "executes attr_gt filters properly" do
      expect(subject.apply(collection, { filters: { int_attr1_gt: 400 } }).count).to eq(0)
      expect(subject.apply(collection, { filters: { int_attr1_goet: 400 } }).count).to eq(1)
      expect(subject.apply(collection, { filters: { int_attr1_gt: 399 } }).count).to eq(1)
      expect(subject.apply(collection, { filters: { date_attr_gt: "04/06/1984".to_date } }).count).to eq(0)
      expect(subject.apply(collection, { filters: { date_attr_goet: "04/06/1984".to_date } }).count).to eq(1)
      expect(subject.apply(collection, { filters: { date_attr_gt: "03/06/1984".to_date } }).count).to eq(1)
    end

    it "executes attr_lt filters properly" do
      expect(subject.apply(collection, { filters: { int_attr1_lt: 400 } }).count).to eq(0)
      expect(subject.apply(collection, { filters: { int_attr1_loet: 400 } }).count).to eq(1)
      expect(subject.apply(collection, { filters: { int_attr1_lt: 401 } }).count).to eq(1)
      expect(subject.apply(collection, { filters: { date_attr_lt: "04/06/1984".to_date } }).count).to eq(0)
      expect(subject.apply(collection, { filters: { date_attr_loet: "04/06/1984".to_date } }).count).to eq(1)
      expect(subject.apply(collection, { filters: { date_attr_lt: "05/06/1984".to_date } }).count).to eq(1)
    end

    it "executes attr string filters properly" do
      expect(subject.apply(collection, { filters: { string_attr_contains: "I'm a" } }).count).to eq(1)
      expect(subject.apply(collection, { filters: { int_attr2_contains: 66 } }).count).to eq(1)
      expect(subject.apply(collection, { filters: { string_attr_contains: "bla" } }).count).to eq(0)
      expect(subject.apply(collection, { filters: { string_attr_starts: "Hi" } }).count).to eq(1)
      expect(subject.apply(collection, { filters: { string_attr_ends: "String" } }).count).to eq(1)
    end
  end
end