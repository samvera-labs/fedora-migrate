require 'spec_helper'

describe "Mirating RDF terms" do

  let(:mover) do
    FedoraMigrate::RDFDatastreamMover.new(
      FedoraMigrate.source.connection.find("sufia:xp68km39w").datastreams["descMetadata"], 
      ExampleModel::RDFProperties.new
    )
  end

  it "should call the before and after hooks when migrating" do
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
