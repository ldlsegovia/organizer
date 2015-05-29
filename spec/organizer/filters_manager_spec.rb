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
end
