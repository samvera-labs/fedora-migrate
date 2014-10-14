require 'spec_helper'

describe "A sample migration" do

  class MigrationModel < ActiveFedora::Base
    property :title, predicate: RDF::DC.title do |index|
      index.as :stored_searchable, :facetable
    end
    property :creator, predicate: RDF::DC.creator do |index|
      index.as :stored_searchable, :facetable
    end
  end

  context "using only an object's metadata" do

    context "consisting only of RDF triples" do

      it "adds each triple to a new Fedora4 resource" do
        expect(ActiveFedora::Base.all.count).to eql 0
        source_repo = FedoraMigrate.source.connection
        obj = source_repo.find("sufia:xp68km39w")
        target = MigrationModel.new(pid: obj.pid.split(/:/).last)
        parser = FedoraMigrate::RDFDatastreamParser.new(target.uri, obj.datastreams["descMetadata"].content)
        parser.parse
        parser.statements.each do |statement|
          target.resource << statement
        end
        target.save
        expect(target.title.first).to eql "Sample Migration Object A"
        expect(target.creator.first).to eql "Adam Wead"
      end

    end

  end

end
