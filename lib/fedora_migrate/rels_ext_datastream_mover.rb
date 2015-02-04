module FedoraMigrate
  class RelsExtDatastreamMover < Mover

    RELS_EXT_DATASTREAM = "RELS-EXT".freeze

    def migrate
      migrate_statements
      target.ldp_source.update
      update_index
    end

    def post_initialize
      @target ||= ActiveFedora::Base.find(source.pid.split(/:/).last)
    rescue ActiveFedora::ObjectNotFoundError
      raise FedoraMigrate::Errors::MigrationError, "Target object was not found in Fedora4. Did you migrated it?"
    end

    private

    def migrate_statements
      statements.each do |statement|
        target.ldp_source.graph << [target.rdf_subject, migrate_predicate(statement.predicate), migrate_object(statement.object)]
      end
    end

    def update_index
      target.reload
      target.update_index
    end

    def graph
      @graph ||= RDF::Graph.new { |g| g.from_rdfxml(source.datastreams[RELS_EXT_DATASTREAM].content) }
    end

    # Override this if any predicate transformation is needed
    def migrate_predicate(fc3_uri)
      fc3_uri
    end

    def migrate_object(fc3_uri)
      RDF::URI.new(ActiveFedora::Base.id_to_uri(id_component(fc3_uri)))
    end

    def is_missing?(uri)
      return false if ActiveFedora::Base.exists?(id_component(uri))
      Logger.warn "#{source.pid} could not migrate relationship to #{uri.to_s} because it doesn't exist in Fedora4"
      true
    end

    def id_component(uri)
      uri.to_s.split(/:/).last
    end

    # All the graph statements except hasModel and those with missing objects
    def statements
      graph.statements.reject { |stmt| stmt.predicate == ActiveFedora::RDF::Fcrepo::Model.hasModel || is_missing?(stmt.object) }
    end

  end
end
