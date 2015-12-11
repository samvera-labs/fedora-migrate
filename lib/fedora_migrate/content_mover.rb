module FedoraMigrate
  class ContentMover < Mover
    include DatastreamVerification

    class Report
      attr_accessor :name, :mime_type, :original_date, :error
      def success?
        error.nil?
      end
    end

    def migrate
      return report if nil_source
      move_content
      report_results
      insert_date_created_by_application
      super
    end

    def results_report
      Report.new
    end

    def move_content
      target.content = source.content
      target.original_name = source.label.try(:gsub, /"/, '\"')
      target.mime_type = source.mimeType
      save
      report.error = "Failed checksum" unless valid?
    end

    def report_results
      report.name = target.original_name
      report.mime_type = target.mime_type
    end

    def insert_date_created_by_application
      result = perform_sparql_insert
      report.original_date = source.createDate.iso8601
      report.error = "There was a problem with sparql #{result.status} #{result.body}" unless result.status == 204
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

      def perform_sparql_insert
        ActiveFedora.fedora.connection.patch(target.metadata.metadata_uri, sparql_insert, "Content-Type" => "application/sparql-update")
      end

      def nil_source
        return unless source.content.nil?
        report.error = "Nil source -- it's probably defined in the target but not present in the source"
        true
      end
  end
end
