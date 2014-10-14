require 'spec_helper'

describe FedoraMigrate::RDFDatastreamParser do

  let(:ds_content) { load_fixture("rdf_ntriples_datastream.txt").read }
  let(:rdf_subject) { 'http://127.0.0.1:8983/fedora/rest/dev/xp/68/km/41/xp68km41x' }
  subject { FedoraMigrate::RDFDatastreamParser.new(rdf_subject, ds_content) }

  describe "::new" do
    it { is_expected.to respond_to(:subject) }
    it { is_expected.to respond_to(:datastream) }
    it { is_expected.to respond_to(:statements) }
  end

  describe "#parse" do

    context "given the raw content from an ActiveFedora::NTriples datastream" do

      subject { FedoraMigrate::RDFDatastreamParser.new(rdf_subject, ds_content) }

      before :each do
        subject.parse
      end

      it "should return an array" do
        expect(subject.statements.count).to eql 2
      end

      it "should consist of RDF::Statment objects" do
        expect(subject.statements.first).to be_kind_of(RDF::Statement)
      end

    end

  end

end

