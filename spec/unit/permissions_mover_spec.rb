require 'spec_helper'

describe FedoraMigrate::PermissionsMover do

  it { is_expected.to respond_to :rightsMetadata }

  describe "#post_initialize" do
    specify "a target is required" do
      expect{subject.new}.to raise_error(StandardError)
    end
  end

  describe "#rightsMetadata" do
    let(:target) { instance_double("Target") }
    let(:source) { instance_double("Source", content: "<rightsMetadata></rightsMetadata>") }

    subject { FedoraMigrate::PermissionsMover.new(source, target) }
    
    it "should be FedoraMigrate::RightsMetadata datastream" do
      expect(subject.rightsMetadata).to be_kind_of FedoraMigrate::RightsMetadata
    end
  
    context "with a user" do
      specify "reading" do
        expect(subject.read_users).to be_empty
      end

      specify "editing" do
        expect(subject.edit_users).to be_empty
      end

      specify "discovering" do
        expect(subject.discover_users).to be_empty 
      end
    end

    context "with a user" do
      specify "reading" do
        expect(subject.read_groups).to be_empty
      end

      specify "editing" do
        expect(subject.edit_groups).to be_empty
      end

      specify "discovering" do
        expect(subject.discover_groups).to be_empty 
      end
    end 

  end

end
