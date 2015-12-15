require 'spec_helper'

describe Organizer::Group::Sort::Applier do
  subject { Organizer::Group::Sort::Applier }
  let_collection(:collection)

  describe "#apply" do
    before do
      operations = Organizer::Operation::Collection.new

      operations.add_group_parent_item(:age_sum) do |parent, item|
        parent.age_sum + item.age
      end

      operations.add_group_parent_item(:greatest_savings) do |parent, item|
        (parent.greatest_savings > item.savings) ? parent.greatest_savings : item.savings
      end

      @group_definitions = Organizer::Group::DefinitionsCollection.new
      @d1 = @group_definitions.add_definition(:gender)
      @d2 = @group_definitions.add_definition(:site_id)
      @d1.parent_item_operations = @d2.parent_item_operations = operations

      group = Organizer::Group::Builder.build(collection, @group_definitions.groups_from_definitions)
      @group = Organizer::Group::Operation::ParentItemsExecutor.execute(@group_definitions, collection, group)
      @sort_items = Organizer::Sort::Collection.new
    end

    it "sorts parent group" do
      @sort_items.add_item(:age_sum)
      @d1.sort_items = @sort_items

      subject.apply(@group_definitions, @group)
      expect(@group.first.age_sum).to eq(130)
      expect(@group.last.age_sum).to eq(192)
    end

    it "sorts child group" do
      @sort_items.add_item(:greatest_savings, true)
      @d2.sort_items = @sort_items

      subject.apply(@group_definitions, @group)
      expect(@group.first.first.greatest_savings).to eq(50.2)
      expect(@group.first.last.greatest_savings).to eq(20.5)
      expect(@group.last.first.greatest_savings).to eq(70.1)
      expect(@group.last.last.greatest_savings).to eq(45.5)
    end
  end
end
