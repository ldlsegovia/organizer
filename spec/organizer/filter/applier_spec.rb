require 'spec_helper'

describe Organizer::Filter::Applier do
  subject { Organizer::Filter::Applier }
  let_collection(:collection)

  describe "#apply" do
    before { @filters = Organizer::Filter::Collection.new }

    context "with default filters" do
      before do
        @filters.add_filter { |item| item.age > 9 }
        @filters.add_filter(:my_filter) { |item| item.age < 33 }
      end

      it "returns filtered collection" do
        expect(subject.apply_default(@filters, collection).size).to eq(3)
      end

      it "skips default filter passing filter to skip_default_filter option" do
        expect(subject.apply_default(@filters, collection, [:my_filter]).size).to eq(8)
      end

      it "skips all default filters :all key to skip_default_filter option" do
        expect(subject.apply_default(@filters, collection, :all).size).to eq(9)
      end
    end

    context "with normal filters" do
      before do
        @filters.add_filter(:filter1) { |item| item.age > 9 }
        @filters.add_filter(:filter2) { |item| item.age < 33 }
      end

      it { expect(subject.apply(@filters, collection).size).to eq(9) }
      it { expect(subject.apply(@filters, collection, filters: [:filter1]).size).to eq(8) }
      it { expect(subject.apply(@filters, collection, filters: [:filter1, :filter2]).size).to eq(3) }
    end

    context "with filters with value" do
      before do
        @filters.add_filter(:filter1) { |item, value| item.age > value }
        @filters.add_filter(:filter2) { |item, value| item.age < value }
      end

      it { expect(subject.apply(@filters, collection).size).to eq(9) }
      it { expect(subject.apply(@filters, collection, filters: { filter1: 9 }).size).to eq(8) }
      it { expect(subject.apply(@filters, collection, filters: { filter1: 9, filter2: 33 }).size).to eq(3) }
    end
  end
end
