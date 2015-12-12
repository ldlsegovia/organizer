require 'spec_helper'

describe Organizer::Sort::Applier do
  subject { Organizer::Sort::Applier }
  let_collection(:collection)
  before { @sort_items = Organizer::Sort::Collection.new }

  describe "#apply" do
    context "with ascendant sort item" do
      before { @sort_items.add_item(:gender) }

      it "sorts collection" do
        result = subject.apply(@sort_items, collection)
        expect(result.first.first_name).to eq("Virginia")
        expect(result.last.first_name).to eq("Javier")
      end
    end

    context "with descendding sort item" do
      before { @sort_items.add_item(:gender, true) }

      it "sorts collection" do
        result = subject.apply(@sort_items, collection)
        expect(result.first.first_name).to eq("Juan Manuel")
        expect(result.last.first_name).to eq("Virginia")
      end

      context "with multiple sort items" do
        before { @sort_items.add_item(:age, true) }

        it "sorts collection" do
          result = subject.apply(@sort_items, collection)
          expect(result.first.first_name).to eq("Rodolfo")
          expect(result.last.first_name).to eq("Virginia")
        end
      end
    end
  end

  describe "#apply_on_groups" do
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
      d1.memo_operations = d2.memo_operations = operations
      groups = Organizer::Group::Builder.build(collection, group_definitions.groups_from_definitions)

      @group = Organizer::Operation::Executor.execute_on_groups(group_definitions, collection, groups)
      @sort_items = Organizer::Sort::Collection.new
    end

    it "sorts parent group" do
      @sort_items.add_item(:age_sum)
      definitions = Organizer::Group::DefinitionsCollection.new
      definitions.add_definition(:gender).sort_items = @sort_items

      subject.apply_on_groups(definitions, @group)
      expect(@group.first.age_sum).to eq(130)
      expect(@group.last.age_sum).to eq(192)
    end

    it "sorts child group" do
      @sort_items.add_item(:greatest_savings, true)
      definitions = Organizer::Group::DefinitionsCollection.new
      definitions.add_definition(:site_id).sort_items = @sort_items

      subject.apply_on_groups(definitions, @group)
      expect(@group.first.first.greatest_savings).to eq(50.2)
      expect(@group.first.last.greatest_savings).to eq(20.5)
      expect(@group.last.first.greatest_savings).to eq(70.1)
      expect(@group.last.last.greatest_savings).to eq(45.5)
    end
  end
end
