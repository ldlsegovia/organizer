require 'spec_helper'

describe Organizer do
  it 'has a version number' do
    expect(Organizer::VERSION).not_to be nil
  end

  describe "#define" do
    before { Object.send(:remove_const, :MyOrganizer) rescue nil }

    it "creates a MyOrganizer class" do
      valid_collection = [{ attr1: "value1" }, { attr1: "value2" }]
      subject.define("my_organizer") { collection { valid_collection } }
      expect(MyOrganizer.new.collection.count).to eq(2)
    end
  end
end
