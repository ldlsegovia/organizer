require 'spec_helper'

describe Organizer::Group::Sort::Applier do
  subject { Organizer::Group::Sort::Applier }
  let_group(:group, true, :gender, :site_id)

  describe "#apply" do
    before { @sort_items = Organizer::Sort::Collection.new }

    it "sorts parent group" do
      @sort_items.add(:lower_age)
      gender_definition.sort_items = @sort_items

      subject.apply(group_definitions, group)
      expect(group.first.lower_age).to eq(8)
      expect(group.last.lower_age).to eq(33)
    end

    it "sorts child group" do
      @sort_items.add(:greater_age, true)
      site_id_definition.sort_items = @sort_items

      subject.apply(group_definitions, group)
      expect(group.first.first.greater_age).to eq(65)
      expect(group.first.last.greater_age).to eq(31)
      expect(group.last.first.greater_age).to eq(64)
      expect(group.last.last.greater_age).to eq(33)
    end
  end
end
