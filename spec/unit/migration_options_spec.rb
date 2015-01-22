require 'spec_helper'

describe FedoraMigrate::MigrationOptions do

  class TestCase
    include FedoraMigrate::MigrationOptions
  end

  describe "#conversion_options" do
    subject do
      TestCase.new.tap do |example|
        example.options = { convert: 'datastream' }
      end
    end
    specify "sets the name of the datastream to convert" do
      expect(subject.conversion_options).to include "datastream"
    end
    it { is_expected.to be_not_forced }
  end

  describe "forced?" do
    subject do
      TestCase.new.tap do |example|
        example.options = { convert: "datastream", force: true }
      end
    end
    it { is_expected.to be_forced }
  end

  describe "forced?" do
    subject do
      TestCase.new.tap do |example|
        example.options = { convert: "datastream", force: false }
      end
    end
    it { is_expected.to be_not_forced }
  end

end
