require 'spec_helper'

describe "Migrating the repository" do

  context "when no target objects are defined" do

    before do
      Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      Object.send(:remove_const, :Batch) if defined?(Batch)
      Object.send(:remove_const, :Collection) if defined?(Collection)
    end

    it "should log warnings" do
      expect(FedoraMigrate::Logger).to receive(:warn).at_least(6).times
      FedoraMigrate.migrate_repository(namespace: "sufia", options: {convert: "descMetadata"})
    end
  end

  context "with all target objects are defined" do

    before do
      Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      class GenericFile < ExampleModel::MigrationObject
        belongs_to :batch, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf
        property :title, predicate: ::RDF::DC.title do |index|
          index.as :stored_searchable, :facetable
        end
        property :creator, predicate: ::RDF::DC.creator do |index|
          index.as :stored_searchable, :facetable
        end
      end

      Object.send(:remove_const, :Batch) if defined?(Batch)
      class Batch < ActiveFedora::Base
        has_many :generic_files, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf
      end

      Object.send(:remove_const, :Collection) if defined?(Collection)
      class Collection < ExampleModel::Collection
      end

      FedoraMigrate.migrate_repository(namespace: "sufia", options: {convert: "descMetadata"})
    end

    after do
      Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      Object.send(:remove_const, :Batch) if defined?(Batch)
      Object.send(:remove_const, :Collection) if defined?(Collection)
    end

    let(:file1) { GenericFile.find("rb68xc089") }
    let(:file2) { GenericFile.find("xp68km39w") }

    it "should move every object" do
      expect(file1.title).to eql ["world.png"]
      expect(file2.title).to eql ["Sample Migration Object A"]
      expect(file2.creator).to eql ["Adam Wead"]
      expect(GenericFile.all.count).to eql 6
      expect(Batch.all.count).to eql 2
      expect(Batch.all.first.generic_files.count).to eql 2
      expect(Batch.all.last.generic_files.count).to eql 2
      expect(Collection.all.count).to eql 1
      expect(Collection.first.members.count).to eql 2
    end

  end

end
