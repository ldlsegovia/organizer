require 'spec_helper'

describe Organizer::Group::Filter::Applier do
  subject { Organizer::Group::Filter::Applier }
  let_collection(:collection)

  describe "#apply" do
    before do
      operations = Organizer::Operation::Collection.new

      operations.add_memo_operation(:age_sum) do |memo, item|
        memo.age_sum + item.age
      end

      operations.add_memo_operation(:greatest_savings) do |memo, item|
        (memo.greatest_savings > item.savings) ? memo.greatest_savings : item.savings
      end

      @group_definitions = Organizer::Group::DefinitionsCollection.new
      @d1 = @group_definitions.add_definition(:site, :site_id)
      @d2 = @group_definitions.add_definition(:store, :store_id)
      @d1.children_based_operations = @d2.children_based_operations = operations

      group = Organizer::Group::Builder.build(collection, @group_definitions.groups_from_definitions)
      @group = Organizer::Operation::GroupParentItemsExecutor.execute(@group_definitions, collection, group)

      @filter_definition = Proc.new do |item, value|
        item.age_sum < value
      end
    end

    it "filters parent group items" do
      filter = Organizer::Filter::Item.new(@filter_definition, :filter)
      filter.value = 150

      @d1.filters << filter
      subject.apply(@group_definitions, @group)

      expect(@group.count).to eq(2)
    end

    it "filters child groups items" do
      filter = Organizer::Filter::Item.new(@filter_definition, :filter)
      filter.value = 50

      @d2.filters << filter
      subject.apply(@group_definitions, @group)

      expect(@group.count).to eq(3)
      expect(@group.first.count).to eq(0)
      expect(@group.second.count).to eq(1)
      expect(@group.third.count).to eq(1)
    end

    it "filters groups items in the complete hierarchy" do
      filter1 = Organizer::Filter::Item.new(@filter_definition, :filter)
      filter1.value = 150
      @d1.filters << filter1

      filter2 = Organizer::Filter::Item.new(@filter_definition, :filter)
      filter2.value = 50
      @d2.filters << filter2

      subject.apply(@group_definitions, @group)
      expect(@group.count).to eq(2)
      expect(@group.first.count).to eq(0)
      expect(@group.second.count).to eq(1)
    end
  end
end
