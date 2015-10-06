require 'spec_helper'

describe Organizer::Filter::Applier do
  subject { Organizer::Filter::Applier }
  let_collection(:collection)

  describe "#apply" do
    before { @filters = Organizer::Filter::Collection.new }

    context "skipping filters" do
      before do
        @filters.add_filter { |item| item.age > 9 }
        @filters.add_filter(:my_filter) { |item| item.age < 33 }
      end

      it "skips filter passing filter name to skipped_filters option" do
        expect(subject.apply(@filters, collection, skipped_filters: [:my_filter]).size).to eq(8)
      end

      it "skips all filters passing :all key to skipped_filters option" do
        expect(subject.apply(@filters, collection, skipped_filters: :all).size).to eq(9)
      end
    end

    context "with normal filters" do
      before do
        @filters.add_filter(:filter1) { |item| item.age > 9 }
        @filters.add_filter(:filter2) { |item| item.age < 33 }
      end

      it { expect(subject.apply(@filters, collection).size).to eq(9) }
      it { expect(subject.apply(@filters, collection, selected_filters: [:filter1]).size).to eq(8) }
      it { expect(subject.apply(@filters, collection, selected_filters: [:filter1, :filter2]).size).to eq(3) }
    end

    context "with filters with value" do
      before do
        @filters.add_filter(:filter1) { |item, value| item.age > value }
        @filters.add_filter(:filter2) { |item, value| item.age < value }
      end

      it { expect(subject.apply(@filters, collection).size).to eq(9) }
      it { expect(subject.apply(@filters, collection, selected_filters: { filter1: 9 }).size).to eq(8) }
      it { expect(subject.apply(@filters, collection, selected_filters: { filter1: 9, filter2: 33 }).size).to eq(3) }
    end
  end
end
