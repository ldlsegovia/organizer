require 'spec_helper'

describe Organizer::Filter::Applier do
  subject { Organizer::Filter::Applier }
  let_collection(:collection)

  context "#apply" do
    before { @filters = Organizer::Filter::Collection.new }

    it "applies filters passed as params" do
      @filters.add_filter(:filter1) { |item| item.age > 9 }
      @filters.add_filter(:filter2) { |item| item.age < 33 }
      expect(subject.apply(@filters, collection).size).to eq(3)
    end

    it "returns complete collection with no filters" do
      expect(subject.apply(@filters, collection).size).to eq(9)
    end
  end

  context "#apply_groups_filters" do
    before do
      groups = Organizer::Group::Collection.new
      groups.add_group(:site, :site_id)
      groups.add_group(:store, :store_id)
      result = Organizer::Group::Builder.build(collection, groups)

      @operations = Organizer::Operation::Collection.new

      @operations.add_memo_operation(:age_sum) do |memo, item|
        memo.age_sum + item.age
      end

      @operations.add_memo_operation(:greatest_savings) do |memo, item|
        (memo.greatest_savings > item.savings) ? memo.greatest_savings : item.savings
      end

      @group = Organizer::Operation::Executor.execute_on_groups(@operations, collection, result)

      @filter_definition = Proc.new do |item, value|
        item.age_sum < value
      end
    end

    it "filters parent group items" do
      filter = Organizer::Filter::Item.new(@filter_definition, :filter)
      filter.value = 150
      subject.apply_groups_filters({ site: [filter] }, @group)

      expect(@group.count).to eq(2)
    end

    it "filters child groups items" do
      filter = Organizer::Filter::Item.new(@filter_definition, :filter)
      filter.value = 50
      subject.apply_groups_filters({ store: [filter] }, @group)

      expect(@group.count).to eq(3)
      expect(@group.first.count).to eq(0)
      expect(@group.second.count).to eq(1)
      expect(@group.third.count).to eq(1)
    end

    it "filters groups items in the complete hierarchy" do
      filter1 = Organizer::Filter::Item.new(@filter_definition, :filter)
      filter1.value = 150
      filter2 = Organizer::Filter::Item.new(@filter_definition, :filter)
      filter2.value = 50

      subject.apply_groups_filters({ site: [filter1], store: [filter2] }, @group)
      expect(@group.count).to eq(2)
      expect(@group.first.count).to eq(0)
      expect(@group.second.count).to eq(1)
    end
  end
end
