require 'spec_helper'

describe Organizer::Operation::MaskBuilder do
  subject { Organizer::Operation::MaskBuilder }

  describe "#build" do
    let_item(:source_item)

    it "raises error passing invalid mask as parameter" do
      expect { subject.build(:age, :invalid_mask) }.to(
        raise_error(Organizer::Operation::MaskBuilderException))
    end

    it "creates desired operation with valid mask" do
      operation = subject.build(:int_attr1, :currency)
      operation.execute(source_item)
      expect(source_item.human_int_attr1).to eq("$400.00")
    end

    it "allows to pass mask as string" do
      operation = subject.build("int_attr1", :percentage)
      operation.execute(source_item)
      expect(source_item.human_int_attr1).to eq("400.000%")
    end

    it "uses custom options" do
      operation = subject.build("int_attr1", :currency, precision: 5)
      operation.execute(source_item)
      expect(source_item.human_int_attr1).to eq("$400.00000")
    end

    it "creates date operation" do
      operation = subject.build(:date_attr, :date)
      operation.execute(source_item)
      expect(source_item.human_date_attr).to eq("1984-06-04")
    end

    it "creates date operation with custom format" do
      operation = subject.build(:date_attr, :date, format: "%Y")
      operation.execute(source_item)
      expect(source_item.human_date_attr).to eq("1984")
    end

    it "creates datetime operation" do
      operation = subject.build(:datetime_attr, :datetime)
      operation.execute(source_item)
      expect(source_item.human_datetime_attr).to eq("1984-06-04 06:06:06")
    end

    it "creates datetime operation with custom format" do
      operation = subject.build(:datetime_attr, :datetime, format: "%Y")
      operation.execute(source_item)
      expect(source_item.human_datetime_attr).to eq("1984")
    end

    it "creates time operation" do
      operation = subject.build(:float_attr, :time)
      operation.execute(source_item)
      expect(source_item.human_float_attr).to eq("00:00:04")
    end

    it "creates time operation from seconds" do
      operation = subject.build(:float_attr, :time_from_seconds)
      operation.execute(source_item)
      expect(source_item.human_float_attr).to eq("00:00:04")
    end

    it "creates time operation from minutes" do
      operation = subject.build(:float_attr, :time_from_minutes)
      operation.execute(source_item)
      expect(source_item.human_float_attr).to eq("00:04:00")
    end

    it "creates time operation from minutes" do
      operation = subject.build(:float_attr, :time_from_hours)
      operation.execute(source_item)
      expect(source_item.human_float_attr).to eq("04:00:00")
    end
  end
end
