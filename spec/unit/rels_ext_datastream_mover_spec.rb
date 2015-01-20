require 'spec_helper'

describe FedoraMigrate::RelsExtDatastreamMover do

  let(:mover) { FedoraMigrate::RelsExtDatastreamMover.new(source) }
  let(:source) { FedoraMigrate.source.connection.find("sufia:rb68xc11m") }
  let(:result) { ActiveFedora::Base.new(id: 'rb68xc11m') }
  let(:query) { result.ldp_source.graph.query([nil, ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf, nil]) }
  before do
    allow(mover).to receive(:retrieve_subject).and_return(result)
    expect(result.ldp_source).to receive(:update)
    expect(result).to receive(:reload)
  end

  subject { mover }

  describe "#migrate" do
    it "migrates relationships" do
      subject.migrate
      expect(query.first.subject).to eq RDF::URI.new('http://localhost:8983/fedora/rest/test/rb68xc11m')
      expect(query.first.object).to eq RDF::URI.new('http://localhost:8983/fedora/rest/test/rb68xc09k')
    end
  end
end
