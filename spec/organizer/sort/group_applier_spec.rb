require 'spec_helper'

describe Organizer::Sort::GroupApplier do
  subject { Organizer::Sort::GroupApplier }
  let_collection(:collection)
  before { @sort_items = Organizer::Sort::Collection.new }

  describe "#apply" do
    before do
      operations = Organizer::Operation::Collection.new

      operations.add_memo_operation(:age_sum) do |memo, item|
        memo.age_sum + item.age
      end

      operations.add_memo_operation(:greatest_savings) do |memo, item|
        (memo.greatest_savings > item.savings) ? memo.greatest_savings : item.savings
      end

      group_definitions = Organizer::Group::DefinitionsCollection.new
      d1 = group_definitions.add_definition(:gender)
      d2 = group_definitions.add_definition(:site_id)
      d1.children_based_operations = d2.children_based_operations = operations
      groups = Organizer::Group::Builder.build(collection, group_definitions.groups_from_definitions)

      @group = Organizer::Operation::GroupParentItemsExecutor.execute(group_definitions, collection, groups)
      @sort_items = Organizer::Sort::Collection.new
    end

    it "sorts parent group" do
      @sort_items.add_item(:age_sum)
      definitions = Organizer::Group::DefinitionsCollection.new
      definitions.add_definition(:gender).sort_items = @sort_items

      subject.apply(definitions, @group)
      expect(@group.first.age_sum).to eq(130)
      expect(@group.last.age_sum).to eq(192)
    end

    it "sorts child group" do
      @sort_items.add_item(:greatest_savings, true)
      definitions = Organizer::Group::DefinitionsCollection.new
      definitions.add_definition(:site_id).sort_items = @sort_items

      subject.apply(definitions, @group)
      expect(@group.first.first.greatest_savings).to eq(50.2)
      expect(@group.first.last.greatest_savings).to eq(20.5)
      expect(@group.last.first.greatest_savings).to eq(70.1)
      expect(@group.last.last.greatest_savings).to eq(45.5)
    end
  end
end
