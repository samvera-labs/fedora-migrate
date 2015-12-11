require 'spec_helper'

describe FedoraMigrate::ObjectMover do
  let(:source) { FedoraMigrate.source.connection.find("sufia:rb68xc089") }
  let(:mover)  { described_class.new source, ExampleModel::MigrationObject.new }

  subject do
    mover.migrate
    mover.target
  end

  # Query the metadata node for a given version and return its hasDateCreatedByApplication expressed as an integer
  def date_created_by_application(version)
    uri = subject.content.versions.with_label(version).uri
    response = ActiveFedora.fedora.connection.get(uri + "/fcr:metadata")
    graph = ::RDF::Graph.new << ::RDF::Reader.for(:ttl).new(response.body)
    value = graph.query(predicate: RDF::URI("http://www.loc.gov/premis/rdf/v1#hasDateCreatedByApplication")).first.object.to_s
    DateTime.iso8601(value).to_i
  end

  def desc_metadata_source_versions
    source.datastreams["descMetadata"].versions.sort { |a, b| a.createDate <=> b.createDate }
  end

  it "is migrated in the order they were created with their original creation dates" do
    pending "Requires fix to Fedora 4.4; awaiting release"
    expect(desc_metadata_source_versions[0].createDate.to_i).to eql date_created_by_application("version1")
    expect(desc_metadata_source_versions[1].createDate.to_i).to eql date_created_by_application("version2")
    expect(desc_metadata_source_versions[2].createDate.to_i).to eql date_created_by_application("version3")
  end
end
