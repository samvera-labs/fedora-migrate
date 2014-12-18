require 'spec_helper'

describe "Migrating the repository" do

  context "when no target objects are defined" do

    before do
      Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      Object.send(:remove_const, :Batch) if defined?(Batch)
    end

    subject do
      results = FedoraMigrate.migrate_repository(namespace: "sufia", options: {convert: "descMetadata"})
      results.map { |e| e.values }.flatten
    end
    it { is_expected.to include("uninitialized constant GenericFile")}
    it { is_expected.to include("uninitialized constant Batch")}
    it { is_expected.to include("Source was not found in Fedora4. Did you migrated it?")}
  end

  context "with all target objects are defined" do

    before do
      Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      class GenericFile < ExampleModel::MigrationObject
        belongs_to :batch, predicate: ActiveFedora::RDF::RelsExt.isPartOf
        property :title, predicate: ::RDF::DC.title do |index|
          index.as :stored_searchable, :facetable
        end
        property :creator, predicate: ::RDF::DC.creator do |index|
          index.as :stored_searchable, :facetable
        end
      end

      Object.send(:remove_const, :Batch) if defined?(Batch)      
      class Batch < ActiveFedora::Base
        has_many :generic_files, predicate: ActiveFedora::RDF::RelsExt.isPartOf
      end
    end

    after do
      Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      Object.send(:remove_const, :Batch) if defined?(Batch)
    end

    it "should move every object" do
      results = FedoraMigrate.migrate_repository(namespace: "sufia", options: {convert: "descMetadata"})
      expect(results.collect { |r| r.values}.flatten.uniq).to eql [true]
      expect(GenericFile.find("rb68xc089").title).to eql(["world.png"])
      expect(GenericFile.find("xp68km39w").title).to eql(["Sample Migration Object A"])
      expect(GenericFile.find("xp68km39w").creator).to eql(["Adam Wead"])
      expect(GenericFile.all.count).to eql 4
      expect(Batch.all.count).to eql 1
      expect(Batch.first.generic_files.count).to eql 2
    end

  end

end
