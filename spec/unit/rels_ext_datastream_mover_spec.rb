require 'spec_helper'

describe FedoraMigrate::RelsExtDatastreamMover do
  
  let(:source) { FedoraMigrate.source.connection.find("sufia:rb68xc11m") }
  let(:query) { subject.target }

  describe "#migrate" do
    context "with an existing target" do
      before do
        ActiveFedora::Base.create(id: 'rb68xc11m')
        ActiveFedora::Base.create(id: 'rb68xc09k')
        FedoraMigrate::RelsExtDatastreamMover.new(source).migrate
      end

      subject { ActiveFedora::Base.find("rb68xc11m").ldp_source.graph.query([nil, ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf, nil]) }

      it "migrates RDF relationships" do
        expect(subject.first.subject).to eq RDF::URI.new('http://localhost:8983/fedora/rest/test/rb68xc11m')
        expect(subject.first.object).to eq RDF::URI.new('http://localhost:8983/fedora/rest/test/rb68xc09k')
      end
    end
    
    context "with a non-existent target" do
      it "raises an error" do
        expect { FedoraMigrate::RelsExtDatastreamMover.new(source) }.to raise_error(FedoraMigrate::Errors::MigrationError)
      end
    end
  end
end
