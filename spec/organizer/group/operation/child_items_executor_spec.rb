require 'spec_helper'

describe Organizer::Group::Operation::ChildItemsExecutor do
  subject { Organizer::Group::Operation::ChildItemsExecutor }
  let_group(:gender, true, :gender, :site_id)

  describe "#execute" do
    before do
      gender_operations = Organizer::Operation::Collection.new

      gender_operations.add(:is_greatest_age) do |site_item, gender_item|
        site_item.greater_age == gender_item.greater_age
      end

      site_operations = Organizer::Operation::Collection.new

      site_operations.add(:age_sum) do |source_item, site_item, gender_item|
        source_item.age + site_item.greater_age + gender_item.greater_age
      end

      gender_definition.child_item_operations = gender_operations
      site_id_definition.child_item_operations = site_operations
      @result = subject.execute(gender_definitions, gender)
    end

    it "returns a group collection" do
      expect(@result.size).to eq(2)
      expect(@result).to be_a(Organizer::Group::Collection)
    end

    it "executes operations respecting group hierarchy" do
      expect(@result.first).to_not respond_to(:is_greatest_age)
      expect(@result.first.first).to respond_to(:is_greatest_age)
      expect(@result.first.first.first).to_not respond_to(:is_greatest_age)
      expect(@result.first).to_not respond_to(:age_sum)
      expect(@result.first.first).to_not respond_to(:age_sum)
      expect(@result.first.first.first).to respond_to(:age_sum)
    end

    it "executes operations using parent items" do
      expect(@result.first.second.is_greatest_age).to be_truthy
      expect(@result.last.last.last.age_sum).to eq(130)
    end
  end
end
