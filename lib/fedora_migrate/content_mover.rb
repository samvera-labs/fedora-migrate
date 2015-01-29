module FedoraMigrate
  class ContentMover < Mover

    def migrate
      return nil_content_message if source.content.nil?
      move_content
      insert_date_created_by_application
    end

    def move_content
      target.content = source.content
      target.original_name = source.label.try(:gsub, /"/, '\"')
      target.mime_type = source.mimeType
      Logger.info "#{target.inspect}"
      save
    end

    def insert_date_created_by_application
      result = perform_sparql_insert
      return true if result.status == 204
      raise FedoraMigrate::Errors::MigrationError, "problem with sparql #{result.status} #{result.body}"
    end

    def sparql_insert
<<-EOF
PREFIX premis: <http://www.loc.gov/premis/rdf/v1#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
DELETE WHERE { ?s premis:hasDateCreatedByApplication ?o } ;
INSERT {
  <> premis:hasDateCreatedByApplication "#{source.createDate.iso8601}"^^xsd:dateTime .
}
WHERE { }
EOF
    end

    private

    def nil_content_message
      Logger.info "datastream '#{source.dsid}' is nil. It's probably defined in the target but not present in the source"
      true
    end

    def perform_sparql_insert
      ActiveFedora.fedora.connection.patch(target.metadata.metadata_uri, sparql_insert, "Content-Type" => "application/sparql-update")
    end

  end

end
