require 'spec_helper'

describe FedoraMigrate::MigrationReport do

  let(:existing_report) { FedoraMigrate::MigrationReport.new("spec/fixtures/sample-report.json") }
  let(:new_report)      { FedoraMigrate::MigrationReport.new }

  context "with an existing report" do
    subject { existing_report }
    it { is_expected.not_to be_empty }
    describe "::results" do
      subject { existing_report.results }
      it { is_expected.to be_kind_of(Hash) }
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
      context "with the default path" do
        it "should write the report" do
          expect(File).to receive(:write).with("report.json", "{\n}")
          new_report.save
        end
      end
      context "with a user-provided path" do
        it "should write the report" do
          expect(File).to receive(:write).with("foo/path/report.json", "{\n}")
          new_report.save("foo/path")
        end
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
  end

end
