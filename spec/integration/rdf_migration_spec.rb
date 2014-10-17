require 'spec_helper'

describe "Mirating RDF terms" do

  class MigrationModel < ActiveFedora::Base
    property :title, predicate: RDF::DC.title do |index|
      index.as :stored_searchable, :facetable
    end
    property :creator, predicate: RDF::DC.creator do |index|
      index.as :stored_searchable, :facetable
    end
  end

  let(:mover) do
    FedoraMigrate::RDFDatastreamMover.new(
      FedoraMigrate.source.connection.find("sufia:xp68km39w").datastreams["descMetadata"], 
      MigrationModel.new
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
