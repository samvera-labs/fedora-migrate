require 'spec_helper'

describe FedoraMigrate::ContentMover do
  let(:nil_source) { double("Source", content: nil, dsid: "datastream") }
  let(:source) do
    double("Source",
           content: "foo",
           dsid: "datastream",
           label: "label",
           mimeType: "mimetype",
           createDate: Time.new(1993, 02, 24, 12, 0, 0, "+09:00") # Rubydora returns Time objects for datastreams' creation dates
          )
  end
  let(:target) { double("Target", content: "", original_name: nil, mime_type: nil) }

  describe "#migrate" do
    context "without content" do
      subject { described_class.new(nil_source, target).migrate }
      it "reports a nil source" do
        expect(subject).to be_kind_of FedoraMigrate::ContentMover::Report
        expect(subject.error).to eql "Nil source -- it's probably defined in the target but not present in the source"
      end
    end
    context "with content" do
      subject { described_class.new(source, target).migrate }
      before do
        allow_any_instance_of(described_class).to receive(:move_content).and_return(true)
        allow_any_instance_of(described_class).to receive(:insert_date_created_by_application).and_return(true)
      end
      it { is_expected.to be_kind_of FedoraMigrate::ContentMover::Report }
    end
  end

  describe "#move_content" do
    before do
      allow(target).to receive(:content=).with("foo")
      allow(target).to receive(:original_name=).with("label")
      allow(target).to receive(:mime_type=).with("mimetype")
      allow(target).to receive(:save).and_return(true)
    end
    subject do
      described_class.new(source, target).move_content
    end
    context "with a valid checksum" do
      before { allow_any_instance_of(described_class).to receive(:valid?).and_return(true) }
      it { is_expected.to be nil }
    end
    context "with an invalid checksum" do
      before { allow_any_instance_of(described_class).to receive(:valid?).and_return(false) }
      it { is_expected.to eql "Failed checksum" }
    end
  end

  describe "#insert_date_created_by_application" do
    subject { described_class.new(source, target).insert_date_created_by_application }
    context "with a successful update" do
      let(:successful_status) { double("Result", status: 204) }
      before { allow_any_instance_of(described_class).to receive(:perform_sparql_insert).and_return(successful_status) }
      it { is_expected.to be nil }
    end
    context "with an unsuccessful update" do
      let(:unsuccessful_status) { double("Result", status: 404, body: "Error!") }
      before { allow_any_instance_of(described_class).to receive(:perform_sparql_insert).and_return(unsuccessful_status) }
      it { is_expected.to eql "There was a problem with sparql 404 Error!" }
    end
  end

  describe "#sparql_insert" do
    let(:sample_sparql_query) do
      <<-EOF
PREFIX premis: <http://www.loc.gov/premis/rdf/v1#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
DELETE WHERE { ?s premis:hasDateCreatedByApplication ?o } ;
INSERT {
  <> premis:hasDateCreatedByApplication "1993-02-24T12:00:00+09:00"^^xsd:dateTime .
}
WHERE { }
EOF
    end
    subject { described_class.new(source, target).sparql_insert }
    it { is_expected.to eql sample_sparql_query }
  end
end
