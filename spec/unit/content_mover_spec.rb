require 'spec_helper'

describe FedoraMigrate::ContentMover do

  let(:nil_source) { double("Source", content: nil, dsid: "datastream") }
  let(:source) do
    double("Source", 
      content: "foo", 
      dsid: "datastream",
      label: "label",
      mimeType: "mimetype",
      createDate: Time.new(1993, 02, 24, 12, 0, 0, "+09:00")  # Rubydora returns Time objects for datastreams' creation dates
    )
  end
  let(:target) { double("Target", content: "") }

  describe "#migrate" do
    context "without content" do
      subject { FedoraMigrate::ContentMover.new(nil_source, target).migrate }
      it { is_expected.to be true }
    end
    context "with content" do
      subject { FedoraMigrate::ContentMover.new(source, target).migrate }
      before do
        allow_any_instance_of(FedoraMigrate::ContentMover).to receive(:move_content).and_return(true)
        allow_any_instance_of(FedoraMigrate::ContentMover).to receive(:insert_date_created_by_application).and_return(true)
      end
      it { is_expected.to be true }
    end
  end

  describe "#move_content" do
    before do
      allow(target).to receive(:content=).with("foo")
      allow(target).to receive(:original_name=).with("label")
      allow(target).to receive(:mime_type=).with("mimetype")
      allow(target).to receive(:save).and_return(true)
      allow_any_instance_of(FedoraMigrate::ContentMover).to receive(:insert_date_created_by_application).and_return(true)
    end
    subject do  
      FedoraMigrate::ContentMover.new(source, target).move_content
    end
    it { is_expected.to be true }
  end

  describe "#insert_date_created_by_application" do
    subject { FedoraMigrate::ContentMover.new(source, target).insert_date_created_by_application }
    context "with a successful update" do
      let(:successful_status) { double("Result", status: 204) }
      before { allow_any_instance_of(FedoraMigrate::ContentMover).to receive(:perform_sparql_insert).and_return(successful_status) }
      it { is_expected.to be true }
    end
    context "with an unsuccessful update" do
      let(:unsuccessful_status) { double("Result", status: 404, body: "Error!") }
      before { allow_any_instance_of(FedoraMigrate::ContentMover).to receive(:perform_sparql_insert).and_return(unsuccessful_status) }
      it "should raise an error" do
        expect { subject }.to raise_error FedoraMigrate::Errors::MigrationError
      end
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
    subject { FedoraMigrate::ContentMover.new(source, target).sparql_insert }
    it { is_expected.to eql sample_sparql_query }
  end

end
