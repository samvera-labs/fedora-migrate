require 'spec_helper'

describe "Mirating RDF terms" do

  let(:mover) do
    FedoraMigrate::RDFDatastreamMover.new(
      FedoraMigrate.source.connection.find("sufia:xp68km39w").datastreams["descMetadata"], 
      ExampleModel::RDFProperties.new
    )
  end

  subject do
    mover.migrate
    mover.target
  end

  it "adds each triple to a new Fedora4 resource" do
    expect(subject.title.first).to eql "Sample Migration Object A"
    expect(subject.creator.first).to eql "Adam Wead"
  end

end
