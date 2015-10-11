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

    context "working with groups" do
      before do
        groups = Organizer::Group::Collection.new
        groups.add_group(:site, :site_id)
        groups.add_group(:store, :store_id)
        result = Organizer::Group::Builder.build(collection, groups, [:site, :store])

        @operations = Organizer::Operation::Collection.new
        @operations.add_memo_operation(:age_sum) do |memo, item|
          memo.age_sum + item.age
        end
        @operations.add_memo_operation(:greatest_savings) do |memo, item|
          (memo.greatest_savings > item.savings) ? memo.greatest_savings : item.savings
        end
        @group = Organizer::Operation::Executor.execute(@operations, collection, result)

        @filters.add_filter(:filter2) { |item, value| item.age_sum < value }
      end

      it "filters parent group items" do
        options = {
          groups_filters: {
            site: {
              filter2: 150
            }
          }
        }

        subject.apply(@filters, @group, options)
        expect(@group.count).to eq(2)
      end

      it "filters child groups items" do
        options = {
          groups_filters: {
            store: {
              filter2: 50
            }
          }
        }

        subject.apply(@filters, @group, options)

        expect(@group.count).to eq(3)
        expect(@group.first.count).to eq(0)
        expect(@group.second.count).to eq(1)
        expect(@group.third.count).to eq(1)
      end

      it "filters groups items in the complete hierarchy" do
        options = {
          groups_filters: {
            site: {
              filter2: 150
            },
            store: {
              filter2: 50
            }
          }
        }

        subject.apply(@filters, @group, options)
        expect(@group.count).to eq(2)
        expect(@group.first.count).to eq(0)
        expect(@group.second.count).to eq(1)
      end
    end
  end
end
