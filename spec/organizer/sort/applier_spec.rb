require 'spec_helper'

describe Organizer::Sort::Applier do
  subject { Organizer::Sort::Applier }
  let_collection(:collection)
  before { @sort_items = Organizer::Sort::Collection.new }

  describe "#apply_on_source" do
    context "with ascendant sort item" do
      before { @sort_items.add_item(:gender) }

      it "sorts collection" do
        result = subject.apply_on_source(@sort_items, collection)
        expect(result.first.first_name).to eq("Virginia")
        expect(result.last.first_name).to eq("Javier")
      end
    end

    context "with descendding sort item" do
      before { @sort_items.add_item(:gender, true) }

      it "sorts collection" do
        result = subject.apply_on_source(@sort_items, collection)
        expect(result.first.first_name).to eq("Juan Manuel")
        expect(result.last.first_name).to eq("Virginia")
      end

      context "with multiple sort items" do
        before { @sort_items.add_item(:age, true) }

        it "sorts collection" do
          result = subject.apply_on_source(@sort_items, collection)
          expect(result.first.first_name).to eq("Rodolfo")
          expect(result.last.first_name).to eq("Virginia")
        end
      end
    end
  end

  describe "#apply_on_groups" do
    before do
      groups = Organizer::Group::Collection.new
      groups.add_group(:gender)
      groups.add_group(:site_id)
      result = Organizer::Group::Builder.build(collection, groups, [:gender, :site_id])

      @operations = Organizer::Operation::Collection.new

      @operations.add_memo_operation(:age_sum) do |memo, item|
        memo.age_sum + item.age
      end

      @operations.add_memo_operation(:greatest_savings) do |memo, item|
        (memo.greatest_savings > item.savings) ? memo.greatest_savings : item.savings
      end

      @group = Organizer::Operation::Executor.execute_on_groups(@operations, collection, result)
      @sort_items = Organizer::Sort::Collection.new
    end

    it "sorts parent group" do
      @sort_items.add_item(:age_sum)
      groups_sort_items = { gender: @sort_items }
      subject.apply_on_groups(groups_sort_items, @group)
      expect(@group.first.age_sum).to eq(130)
      expect(@group.last.age_sum).to eq(192)
    end

    it "sorts child group" do
      @sort_items.add_item(:greatest_savings, true)
      groups_sort_items = { site_id: @sort_items }
      subject.apply_on_groups(groups_sort_items, @group)
      expect(@group.first.first.greatest_savings).to eq(50.2)
      expect(@group.first.last.greatest_savings).to eq(20.5)
      expect(@group.last.first.greatest_savings).to eq(70.1)
      expect(@group.last.last.greatest_savings).to eq(45.5)
    end
  end
end
