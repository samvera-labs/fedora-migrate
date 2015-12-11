require 'spec_helper'

describe FedoraMigrate::RDFDatastreamMover do
  let(:mover) { described_class.new(file, ExampleModel::RDFProperties.new) }

  context "normal record" do
    let(:file) { FedoraMigrate.source.connection.find("sufia:xp68km39w").datastreams["descMetadata"] }

    it "calls the before and after hooks when migrating" do
      expect(mover).to receive(:before_rdf_datastream_migration)
      expect(mover).to receive(:after_rdf_datastream_migration)
      mover.migrate
    end

    describe "using triples" do
      subject do
        mover.migrate
        mover.target
      end

      it "adds each triple to a new Fedora4 resource" do
        expect(subject.title.first).to eql "Sample Migration Object A"
        expect(subject.creator.first).to eql "Adam Wead"
      end
    end
  end

  context "record with UTF8 chracters" do
    let(:file) { FedoraMigrate.source.connection.find("scholarsphere:7d279232g").datastreams["descMetadata"] }

    describe "using triples" do
      subject do
        mover.migrate
        mover.target
      end

      it "adds each triple to a new Fedora4 resource" do
        expect(subject.title.first).to eql "Emerging Role of Genomic Profiling of Advanced Tumors to Aid in Treatment Selection: What Nurses Should Know"
        expect(subject.creator.first).to eql "Eileen Bannon, RN, MSN, OCN, CBCN"
        expect(subject.description.first). to eql "Objectives:\r\n•  Explain the role of a new genomic assay (Target Now™) in guiding oncology treatment plans.\r\n•  Describe the Target Now™ assay.\r\n•  Present a case study where Target Now™ was instrumental in the patient’s treatment plan."
      end
    end
  end
end
