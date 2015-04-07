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

  describe "#forced?" do
    context "when set to true" do
      subject do
        TestCase.new.tap do |example|
          example.options = { convert: "datastream", force: true }
        end
      end
      it { is_expected.to be_forced }
    end
    context "when set to false" do
      subject do
        TestCase.new.tap do |example|
          example.options = { force: false }
        end
      end
      it { is_expected.to be_not_forced }
    end
    context "by default" do
      subject { TestCase.new }
      it { is_expected.to be_not_forced }
    end
  end

  describe "#application_creates_versions" do
    context "by default" do
      subject do
        TestCase.new.application_creates_versions?
      end
      it { is_expected.to be false }
    end
    context "when our own Hydra application creates versions" do
      subject do
        TestCase.new.tap do |example|
          example.options = { application_creates_versions: true }
        end
      end
      it { is_expected.to be_application_creates_versions }
    end
  end

  describe "#blacklist" do
    context "by default" do
      subject { TestCase.new.blacklist }
      it { is_expected.to be_empty }
    end
    context "with a list of pids" do
      let(:blacklist) { ["pid1, pid2"] }
      subject do
        TestCase.new.tap do |example| 
          example.options = { blacklist: blacklist }
        end
      end
      it "returns the list of pids" do
        expect(subject.blacklist).to eql blacklist
      end
    end
  end

end
