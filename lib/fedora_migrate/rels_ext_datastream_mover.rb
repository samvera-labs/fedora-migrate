module FedoraMigrate
  class RelsExtDatastreamMover < Mover

    RELS_EXT_DATASTREAM = "RELS-EXT".freeze

    def migrate
      statements.each do |statement|
        subject.ldp_source.graph << [subject.rdf_subject, migrate_predicate(statement.predicate), migrate_object(statement.object)]
      end
      subject.ldp_source.update
      update_index
    end

    private

    def update_index
      subject.reload
      subject.update_index
    end

    def graph
      @graph ||= RDF::Graph.new { |g| g.from_rdfxml(rels_ext_content) }
    end

    def rels_ext_content
      source.datastreams[RELS_EXT_DATASTREAM].content
    end

    # Override this if any predicate transformation is needed
    def migrate_predicate(fc3_uri)
      fc3_uri
    end

    def migrate_object(fc3_uri)
      RDF::URI.new(ActiveFedora::Base.id_to_uri(id_component(fc3_uri)))
    end

    def id_component(uri)
      uri.to_s.split(/:/).last
    end

    def subject
      @subject ||= retrieve_subject
    end

    # All the graph statements except hasModel
    def statements
      graph.statements.reject { |stmt| stmt.predicate == ActiveFedora::RDF::Fcrepo::Model.hasModel }
    end

    def retrieve_subject
      @subject = ActiveFedora::Base.find(source.pid.split(/:/).last)
    rescue ActiveFedora::ObjectNotFoundError
      raise FedoraMigrate::Errors::MigrationError, "Source was not found in Fedora4. Did you migrated it?"
    end
  end
end
