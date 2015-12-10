require 'spec_helper'

describe FedoraMigrate do
  context "when no target objects are defined" do
    before do
      Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      Object.send(:remove_const, :Batch) if defined?(Batch)
      Object.send(:remove_const, :Collection) if defined?(Collection)
    end

    subject { described_class.migrate_repository(namespace: "sufia", options: { convert: "descMetadata" }).report }

    it "reports warnings" do
      expect(subject.failed_objects.count).to eql 9
    end
  end

  context "when all target objects are defined" do
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
    end

    after do
      Object.send(:remove_const, :GenericFile) if defined?(GenericFile)
      Object.send(:remove_const, :Batch) if defined?(Batch)
      Object.send(:remove_const, :Collection) if defined?(Collection)
    end

    let(:file1) { GenericFile.find("rb68xc089") }
    let(:file2) { GenericFile.find("xp68km39w") }
    let(:versions_report) { GenericFile.all.map { |f| f.content.versions.count }.uniq }

    context "by default" do
      before { described_class.migrate_repository(namespace: "sufia", options: { convert: "descMetadata" }) }
      it "moves every object and its versions" do
        expect(file1.title).to eql ["world.png"]
        expect(file2.title).to eql ["Sample Migration Object A"]
        expect(file2.creator).to eql ["Adam Wead"]
        expect(GenericFile.all.count).to eql 6
        expect(Batch.all.count).to eql 2
        expect(Batch.all.first.generic_files.count).to eql 2
        expect(Batch.all.last.generic_files.count).to eql 2
        expect(Collection.all.count).to eql 1
        expect(Collection.first.members.count).to eql 2
        expect(versions_report).to match_array [0, 3, 9]
      end
    end

    context "and the application will create versions" do
      before do
        described_class.migrate_repository(namespace: "sufia",
                                           options: { convert: "descMetadata", application_creates_versions: true }
                                          )
      end
      it "moves every object but not its versions" do
        expect(file1.title).to eql ["world.png"]
        expect(versions_report).to eql [0]
      end
    end

    context "with an existing report" do
      let(:sample_report)   { "spec/fixtures/reports/failed" }
      let(:failed_report)   { "failed" }
      let(:new_report)      { FedoraMigrate::MigrationReport.new(failed_report) }
      let(:original_report) { FedoraMigrate::MigrationReport.new(sample_report) }
      let(:sample_pid)      { "sufia:rb68xc089" }
      before do
        FileUtils.rm_rf(failed_report)
        FileUtils.cp_r(sample_report, failed_report)
        described_class.migrate_repository(namespace: "sufia", options: { convert: "descMetadata", report: failed_report })
      end
      after { FileUtils.rm_rf(failed_report) }
      it "only migrates the objects that have failed" do
        expect(GenericFile.all.count).to eql 1
        expect(Batch.all.count).to eql 1
        expect(Collection.all.count).to eql 0
        expect(new_report.total_objects).to eql 9
        expect(original_report.results[sample_pid]["status"]).to be false
        expect(new_report.results[sample_pid]["status"]).to be true
        expect(new_report.results[sample_pid]["object"]).to_not be_nil
      end
    end

    context "with a blacklist" do
      let(:pid1) { "sufia:rb68xc089" }
      let(:pid2) { "sufia:xp68km39w" }
      let(:report) { FedoraMigrate::MigrationReport.new }
      before { described_class.migrate_repository(namespace: "sufia", options: { convert: "descMetadata", blacklist: [pid1, pid2] }) }
      subject { report.results.keys }
      it { is_expected.to_not include(pid1) }
    end
  end
end
