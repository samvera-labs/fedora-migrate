require 'spec_helper'

describe FedoraMigrate::RepositoryMigrator do

  let(:namespace) { "sufia" }

  it { is_expected.to respond_to(:source_objects) }
  it { is_expected.to respond_to(:results) }
  it { is_expected.to respond_to(:namespace) }

  describe "#results" do
    specify "are initially empty" do
      expect(subject.results).to eql([])
    end
  end

  context "without a given namespace" do
    describe "#namespace" do
      specify "is given in the repository profile" do
        expect(subject.namespace).to eql("changeme")
      end
    end
  end

  context "with a given namespace" do
    subject { FedoraMigrate::RepositoryMigrator.new(namespace) }
    describe "#namespace" do
      specify "is the one provided" do
        expect(subject.namespace).to eql(namespace)
      end
    end
    describe "#source_objects" do
      it "should reuturn an array of all digital objects from Rubydora" do
        expect(subject.source_objects.collect { |o| o.pid }).to include("sufia:rb68xc089", "sufia:rb68xc11m")
      end
      it "should exclude fedora-system objects" do
        expect(subject.source_objects).to_not include("fedora-system:ContentModel-3.0")
        expect(subject.source_objects.count).to eql 5
      end
    end
  end

end
