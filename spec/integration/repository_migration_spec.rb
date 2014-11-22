require 'spec_helper'

describe "Migrating the repository" do

  context "with all target objects are defined" do

    before do
      class GenericFile < ExampleModel::MigrationObject
        property :title, predicate: ::RDF::DC.title do |index|
          index.as :stored_searchable, :facetable
        end
        property :creator, predicate: ::RDF::DC.creator do |index|
          index.as :stored_searchable, :facetable
        end
      end
      
      class Batch < ActiveFedora::Base
        end
    end

    after do
      Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      Object.send(:remove_const, :Batch) if defined?(Batch)
    end

    it "should move every object" do
      results = FedoraMigrate.migrate_repository(namespace: "sufia", options: {convert: "descMetadata"})
      expect(results.collect { |r| r.values}.flatten).to include(true, nil)
      expect(GenericFile.find("rb68xc089").title).to eql(["world.png"])
      expect(GenericFile.find("xp68km39w").title).to eql(["Sample Migration Object A"])
      expect(GenericFile.find("xp68km39w").creator).to eql(["Adam Wead"])
      expect(GenericFile.all.count).to eql 4
      expect(Batch.all.count).to eql 1
    end

  end

end
