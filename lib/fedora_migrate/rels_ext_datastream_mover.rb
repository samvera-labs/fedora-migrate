module FedoraMigrate
  class RelsExtDatastreamMover < Mover

    RELS_EXT_DATASTREAM = "RELS-EXT".freeze

    def migrate
      migrate_statements
      target.ldp_source.update
      update_index
      super
    end

    def post_initialize
      @target ||= ActiveFedora::Base.find(id_component)
    rescue ActiveFedora::ObjectNotFoundError
      raise FedoraMigrate::Errors::MigrationError, "Target object was not found in Fedora 4. Did you migrate it?"
    end

    private

    def migrate_statements
      statements.each do |statement|
        triple = [target.rdf_subject, migrate_predicate(statement.predicate), migrate_object(statement.object)]
        target.ldp_source.graph << triple
        report << triple.join("--")
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

    def has_missing_object?(statement)
      return false if ActiveFedora::Base.exists?(id_component(statement.object))
      report << "could not migrate relationship #{statement.predicate} because #{statement.object} doesn't exist in Fedora 4"
      true
    end

    # All the graph statements except hasModel and those with missing objects
    def statements
      graph.statements.reject { |stmt| stmt.predicate == ActiveFedora::RDF::Fcrepo::Model.hasModel || has_missing_object?(stmt) }
    end

  end
end
