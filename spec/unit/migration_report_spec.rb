require 'spec_helper'

describe FedoraMigrate::MigrationReport do

  let(:path)            { "spec/fixtures/reports/sample" }
  let(:default_path)    { "migration_report" }
  let(:existing_report) { FedoraMigrate::MigrationReport.new(path) }
  let(:new_report)      { FedoraMigrate::MigrationReport.new }

  context "with an existing report" do
    subject { existing_report }
    it { is_expected.not_to be_empty }
    describe "::results" do
      subject { existing_report.results }
      it { is_expected.to be_kind_of(Hash) }
    end
    describe "::path" do
      subject { existing_report.path }
      it { is_expected.to eql path }
    end
    describe "::failed_objects" do
      subject { existing_report.failed_objects }
      it { is_expected.to include("scholarsphere:6395wb555", "scholarsphere:x346dm27k") }
    end
    describe "::failures" do
      subject { existing_report.failures }    
      context "when the report contains failed migrations" do
        it { is_expected.to eq 2 }
      end
    end
    describe "::total_objects" do
      subject { existing_report.total_objects }
      it { is_expected.to eq 5 }
    end
    describe "::report_failures" do
      subject { existing_report.report_failures }   
      it { is_expected.to be_kind_of(String) }
    end
    describe "::save" do
      let(:individual_report) { Hash.new }
      let(:pid) { "some:pid" }
      it "should write the report" do
        expect(File).to receive(:write).with("migration_report/some_pid.json", "{\n}")
        new_report.save(pid, individual_report)
      end
    end
  end

  context "as a new report" do
    subject { new_report }
    it { is_expected.to be_empty }
    describe "::results" do
      subject { new_report.results }
      it { is_expected.to be_kind_of(Hash) }
    end
    describe "::path" do
      subject { new_report.path }
      it { is_expected.to eql default_path }
    end
  end
end
