require 'spec_helper'

describe FedoraMigrate::RelsExtDatastreamMover do
  let(:file_id)  { "rb68xc11m" }
  let(:batch_id) { "rb68xc09k" }
  let(:source)   { FedoraMigrate.source.connection.find("sufia:#{file_id}") }
  let(:query)    { subject.target }

  context "with target objects present in Fedora 4" do
    before do
      ActiveFedora::Base.create(id: file_id)
      ActiveFedora::Base.create(id: batch_id)
    end

    describe "#initialize" do
      context "without a target" do
        subject { described_class.new(source).target }
        it { is_expected.to be_kind_of(ActiveFedora::Base) }
      end
      context "with a supplied target" do
        subject { described_class.new(source, "a target").target }
        it { is_expected.to eql "a target" }
      end
    end

    describe "#migrate" do
      context "with an existing target" do
        before  { described_class.new(source).migrate }
        subject { ActiveFedora::Base.find(file_id).ldp_source.graph.query([nil, ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf, nil]) }
        it "migrates RDF relationships" do
          expect(subject.first.subject).to eq RDF::URI.new("http://localhost:8983/fedora/rest/test/#{file_id}")
          expect(subject.first.object).to eq RDF::URI.new("http://localhost:8983/fedora/rest/test/#{batch_id}")
        end
      end
    end
  end

  context "with a non-existent target" do
    let(:error_message) { "Target object was not found in Fedora 4. Did you migrate it?" }
    it "raises an error" do
      expect { described_class.new(source) }.to raise_error(FedoraMigrate::Errors::MigrationError, error_message)
    end
  end
end
