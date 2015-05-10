require 'spec_helper'

describe Organizer do

  it 'has a version number' do
    expect(Organizer::VERSION).not_to be nil
  end

  describe "#define" do

    it "creates a Organizer::Data class" do
      subject.define("data")
      expect(subject.const_defined?("Data")).to be_truthy
    end

    it "raises error with invalid organizer name" do
      expect { subject.define("invalid*class<name") }.to raise_organizer_error(:invalid_organizer_name)
    end

    it "raises error with nil organizer name" do
      expect { subject.define(nil) }.to raise_organizer_error(:invalid_organizer_name)
    end

  end

end
