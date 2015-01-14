module FedoraMigrate
  class RDFDatastreamMover < Mover

    attr_accessor :parser

    def post_initialize
      @parser = FedoraMigrate::RDFDatastreamParser.new(target.uri, source.content)
      @parser.parse
    end

    def migrate
      Logger.info "converting datastream '#{source.dsid}' to RDF"
      before_rdf_datastream_migration
      migrate_rdf_triples
      after_rdf_datastream_migration
      save
    end

    def migrate_rdf_triples
      parser.statements.each do |statement|
        apply_term(statement)
      end
      force_attribute_change
    end

    private

    # Date modified has to be treated differently, otherwise it attempts to set the date to
    # today as well as the original date. This results in a ActiveFedora::Constraint error
    # because the term can only have one value.
    def apply_term statement
      if statement.predicate.path.match(/modified$/)
        target.date_modified = Date.parse(statement.object.value) if target.respond_to?(:date_modified)
      else
        target.resource << statement 
      end
    end

    # See projecthydra/active_fedora#540
    # Forcibly setting each attribute's changed status to true
    def force_attribute_change
      target.class.delegated_attributes.keys.each do |term|
        target.send(term+"_will_change!") unless blacklist.member?(term)
      end
    end

    def blacklist
      [ "date_uploaded", "date_modified" ]
    end

  end
end
