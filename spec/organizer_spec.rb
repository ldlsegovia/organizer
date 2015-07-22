require 'spec_helper'

describe Organizer do
  it 'has a version number' do
    expect(Organizer::VERSION).not_to be nil
  end

  describe "#define" do
    before { Object.send(:remove_const, :MyOrganizer) rescue nil }

    it "creates a MyOrganizer class" do
      expect { MyOrganizer }.to raise_error(NameError)
      subject.define("my_organizer") {}
      expect(MyOrganizer.superclass).to be(Organizer::Base)
    end
  end
end
