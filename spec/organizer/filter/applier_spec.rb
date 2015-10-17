require 'spec_helper'

describe Organizer::Filter::Applier do
  subject { Organizer::Filter::Applier }
  let_collection(:collection)

  before { @filters = Organizer::Filter::Collection.new }

  context "#apply_except_skipped" do
    before do
      @filters.add_filter { |item| item.age > 9 }
      @filters.add_filter(:my_filter) { |item| item.age < 33 }
    end

    it "skips specific filter" do
      expect(subject.apply_except_skipped(@filters, collection, [:my_filter]).size).to eq(8)
    end

    it "skips all filters" do
      expect(subject.apply_except_skipped(@filters, collection, :all).size).to eq(9)
    end
  end

  context "#apply_selected" do
    context "without value" do
      before do
        @filters.add_filter(:filter1) { |item| item.age > 9 }
        @filters.add_filter(:filter2) { |item| item.age < 33 }
      end

      it { expect(subject.apply_selected(@filters, collection).size).to eq(9) }
      it { expect(subject.apply_selected(@filters, collection, [:filter1]).size).to eq(8) }
      it { expect(subject.apply_selected(@filters, collection, [:filter1, :filter2]).size).to eq(3) }
    end

    context "with value" do
      before do
        @filters.add_filter(:filter1) { |item, value| item.age > value }
        @filters.add_filter(:filter2) { |item, value| item.age < value }
      end

      it { expect(subject.apply_selected(@filters, collection).size).to eq(9) }
      it { expect(subject.apply_selected(@filters, collection, filter1: 9).size).to eq(8) }
      it { expect(subject.apply_selected(@filters, collection, filter1: 9, filter2: 33).size).to eq(3) }
    end
  end

  context "#apply_selected_on_groups" do
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

      @group = Organizer::Operation::Executor.execute_on_groups(@operations, collection, result)

      @filters.add_filter(:filter2) { |item, value| item.age_sum < value }
    end

    it "filters parent group items" do
      options = { site: { filter2: 150 } }
      subject.apply_selected_on_groups(@filters, @group, options)
      expect(@group.count).to eq(2)
    end

    it "filters child groups items" do
      options = { store: { filter2: 50 } }
      subject.apply_selected_on_groups(@filters, @group, options)
      expect(@group.count).to eq(3)
      expect(@group.first.count).to eq(0)
      expect(@group.second.count).to eq(1)
      expect(@group.third.count).to eq(1)
    end

    it "filters groups items in the complete hierarchy" do
      options = { site: { filter2: 150 }, store: { filter2: 50 } }
      subject.apply_selected_on_groups(@filters, @group, options)
      expect(@group.count).to eq(2)
      expect(@group.first.count).to eq(0)
      expect(@group.second.count).to eq(1)
    end
  end
end
