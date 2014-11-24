require 'spec_helper'

describe FedoraMigrate::RelsExtDatastreamMover do

  context "with a target" do

    before do
      allow_any_instance_of(FedoraMigrate::RelsExtDatastreamMover).to receive(:retrieve_subject).and_return("subject")
      allow_any_instance_of(FedoraMigrate::RelsExtDatastreamMover).to receive(:retrieve_object).and_return("object")
    end

    subject do
      FedoraMigrate::RelsExtDatastreamMover.new(
        FedoraMigrate.source.connection.find("sufia:rb68xc11m")
      )
    end

    describe "#relationships" do
      it "should parse the source's RELS-EXT datastream for relationships" do
        expect(subject.relationships).to include(:part_of => ["object"])
      end
    end

    describe "#ng_xml" do
      it "should return a Nokogiri document of the object's RELS-EXT datastream" do
        expect(subject.ng_xml).to be_kind_of(Nokogiri::XML::Document)
      end
    end

    describe "#has_relationships?" do
      it { is_expected.to have_relationships }
    end

  end

end
