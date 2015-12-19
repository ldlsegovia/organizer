require 'spec_helper'

describe Organizer::Group::Filter::Applier do
  subject { Organizer::Group::Filter::Applier }
  let_group(:group, true, :site_id, :store_id)
  let!(:filter_proc) do
    Proc.new do |item, value|
      item.greater_age > value
    end
  end

  describe "#apply" do
    it "filters parent group items" do
      filter = Organizer::Filter::Item.new(filter_proc, :filter)
      filter.value = 33

      site_id_definition.filters << filter
      subject.apply(group_definitions, group)

      expect(group.count).to eq(2)
    end

    it "filters child groups items" do
      filter = Organizer::Filter::Item.new(filter_proc, :filter)
      filter.value = 33

      store_id_definition.filters << filter
      subject.apply(group_definitions, group)

      expect(group.count).to eq(3)
      expect(group.first.count).to eq(0)
      expect(group.second.count).to eq(1)
      expect(group.third.count).to eq(1)
    end

    it "filters groups items in the complete hierarchy" do
      filter1 = Organizer::Filter::Item.new(filter_proc, :filter)
      filter1.value = 33
      site_id_definition.filters << filter1

      filter2 = Organizer::Filter::Item.new(filter_proc, :filter)
      filter2.value = 33
      store_id_definition.filters << filter2

      subject.apply(group_definitions, group)

      expect(group.count).to eq(2)
      expect(group.first.count).to eq(1)
      expect(group.second.count).to eq(1)
    end
  end
end
