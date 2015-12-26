require 'spec_helper'

describe Organizer::Group::Operation::ParentItemsExecutor do
  subject { Organizer::Group::Operation::ParentItemsExecutor }
  let_group(:gender, false, :gender)

  describe "#execute_based_on_children" do
    before do
      operations = Organizer::Operation::Collection.new

      operations.add(:age_sum, initial_value: 0) do |parent, item|
        parent.age_sum + item.age
      end

      gender_definition.parent_item_operations = operations
      @result = subject.execute(gender_definitions, gender_source_collection, gender)
    end

    it "returns a group collection" do
      expect(@result.size).to eq(2)
      expect(@result).to be_a(Organizer::Group::Collection)
    end

    it "returns group items with new attribute" do
      expect(@result.first.age_sum).to eq(192)
      expect(@result.last.age_sum).to eq(130)
    end
  end
end
