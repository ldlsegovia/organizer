require 'spec_helper'

describe Organizer do

  it 'has a version number' do
    expect(Organizer::VERSION).not_to be nil
  end

  describe "define method" do

    before do
      Object.send(:remove_const, :MyOrganizer) rescue nil
    end

    it "creates a MyOrganizer class" do
      subject.define("my_organizer") {}
      expect(Object.const_defined?("MyOrganizer")).to be_truthy
      expect(MyOrganizer.superclass).to be(OrganizerBase)
    end

    it "raises error with invalid organizer name" do
      expect { subject.define("invalid*class<name") }.to(
        raise_organizer_error(:invalid_organizer_name))
    end

    it "raises error with nil organizer name" do
      expect { subject.define(nil) }.to(
        raise_organizer_error(:invalid_organizer_name))
    end

    describe "collection method" do

      it "creates the collection instance method on the generated MyOrganizer class" do
        valid_collection = [{ attr1: "value1" }, { attr1: "value2" }]

        subject.define("my_organizer") do
          collection { valid_collection }
        end

        collection = MyOrganizer.new.send(:collection)
        expect(collection).to be_a(OrganizedCollection)
        expect(collection.count).to eq(2)
      end

    end

  end

end
