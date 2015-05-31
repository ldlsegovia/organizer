require 'spec_helper'

describe Organizer::FiltersManager do
  let_organizer_collection(:organizer_collection)

  shared_examples :filters_collection do |_filter_method, _filters_collection, _error_class|
    it "adds new object with definition to collection" do
      proc = Proc.new {}
      expect(subject.send(_filters_collection).size).to eq(0)
      filter_one = subject.send(_filter_method, :filter_one, &proc)
      expect(filter_one.name).to eq(:filter_one)
      expect(subject.send(_filters_collection).size).to eq(1)
      filter_two = subject.send(_filter_method, :filter_two, &proc)
      expect(filter_two.name).to eq(:filter_two)
      expect(subject.send(_filters_collection).size).to eq(2)
    end

    it "raises error with repeated name for filter" do
      skip
    end
  end

  describe "#add_default_filter" do
    it_should_behave_like(:filters_collection,
      :add_default_filter, :default_filters, Organizer::FilterException)

    it "adds default filter without a name" do
      proc = Proc.new {}
      expect(subject.send(:default_filters).size).to eq(0)
      subject.add_default_filter(nil, &proc)
      expect(subject.send(:default_filters).size).to eq(1)
    end
  end

  describe "#add_normal_filter" do
    it_should_behave_like(:filters_collection,
      :add_normal_filter, :normal_filters, Organizer::FilterException)
  end

  describe "#apply" do
    context "with default filters" do
      before do
        subject.add_default_filter { |item| item.attr1 > 4 }
        subject.add_default_filter(:my_filter) { |item| item.attr1 < 80 }
      end

      it "returns filtered collection" do
        result = subject.apply(organizer_collection)
        expect(result.size).to eq(1)
        expect(result.first.attr1).to eq(organizer_collection.second.attr1)
      end

      it "skips default filter passing filter to skip_default_filter option" do
        result = subject.apply(organizer_collection, { skip_default_filters: [:my_filter] })
        expect(result.size).to eq(2)
      end

      it "skips all default filters :all key to skip_default_filter option" do
        result = subject.apply(organizer_collection, { skip_default_filters: :all })
        expect(result.size).to eq(3)
      end
    end

    context "with normal filters" do
      before do
        subject.add_normal_filter(:filter1) { |item| item.attr1 > 4 }
        subject.add_normal_filter(:filter2) { |item| item.attr1 < 80 }
      end

      it "returns filtered collection" do
        expect(subject.apply(organizer_collection).size).to eq(3)
        expect(subject.apply(organizer_collection, enabled_filters: [:filter1]).size).to eq(2)
        expect(subject.apply(organizer_collection, enabled_filters: [:filter1, :filter2]).size).to eq(1)
      end
    end

    context "with filters with value" do
      before do
        subject.add_filter_with_value(:filter1) { |item, value| item.attr1 > value }
        subject.add_filter_with_value(:filter2) { |item, value| item.attr1 < value }
      end

      it "returns filtered collection" do
        expect(subject.apply(organizer_collection).size).to eq(3)
        expect(subject.apply(organizer_collection, filters: { filter1: 4 }).size).to eq(2)
        expect(subject.apply(organizer_collection, filters: { filter1: 4, filter2: 80 }).size).to eq(1)
      end
    end
  end

  describe "#generate_usual_filters" do
    let_item(:item)
    let(:collection) { Organizer::Collection.new << item }
    before do
      subject.generate_usual_filters(item)
      @all_filters = subject.send(:all_filters)
    end

    it "raise exception if _item is not an Organizer::Item" do
      expect { subject.generate_usual_filters("not an item") }.to(
        raise_organizer_error(Organizer::FiltersManagerException, :generate_over_organizer_items_only))
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

    it "executes attr_not_eq filters properly", focus: true do
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
