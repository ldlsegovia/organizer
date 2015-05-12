require 'spec_helper'

describe Organizer do

  it 'has a version number' do
    expect(Organizer::VERSION).not_to be nil
  end

  describe "define method" do

    before do
      Object.send(:remove_const, :MyOrganizer) if Object.const_defined?("MyOrganizer")
    end

    it "creates a MyOrganizer class" do
      subject.define("my_organizer") {}
      expect(Object.const_defined?("MyOrganizer")).to be_truthy
      expect(MyOrganizer.superclass).to be(OrganizerBase)
    end

    it "raises error with invalid organizer name" do
      expect { subject.define("invalid*class<name") }.to raise_organizer_error(:invalid_organizer_name)
    end

    it "raises error with nil organizer name" do
      expect { subject.define(nil) }.to raise_organizer_error(:invalid_organizer_name)
    end

    describe "collection method" do

      it "creates the collection instance method on the generated MyOrganizer class" do
        subject.define("my_organizer") { collection {} }
        expect(MyOrganizer.new.respond_to?(:collection, true)).to be_truthy
      end

      it "raises error with undefined collection" do
        subject.define("my_organizer") {}
        expect { MyOrganizer.new.collection }.to raise_organizer_error(:undefined_collection_method)
      end

      it "raises error with collection method not returning an Array collection" do
        subject.define("my_organizer") do
          collection { "I'm not an array" }
        end

        expect { MyOrganizer.new.send(:collection) }.to raise_organizer_error(:invalid_collection_structure)
      end

      it "raises error with collection method not returning a Array of Hashes" do
        subject.define("my_organizer") do
          collection { ["I'm not a hash"] }
        end

        expect { MyOrganizer.new.send(:collection) }.to raise_organizer_error(:invalid_collection_item_structure)
      end

      it "returns valid defined collection" do
        valid_collection = [{ attr1: "value1" }, { attr1: "value2" }]

        subject.define("my_organizer") do
          collection { valid_collection }
        end

        expect(MyOrganizer.new.send(:collection)).to eq(valid_collection)
      end

    end

  end

end
