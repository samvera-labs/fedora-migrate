module FedoraMigrate
  class RDFDatastreamMover < Mover

    def migrate
      Logger.info "converting datastream '#{source.dsid}' to RDF"
      parse_rdf_triples
      force_attribute_change
      save
    end

    def parse_rdf_triples
      parser = FedoraMigrate::RDFDatastreamParser.new(target.uri, source.content)
      parser.parse
      parser.statements.each do |statement|
        target.resource << statement
      end
    end

    # See projecthydra/active_fedora#540
    # Forcibly setting each attribute's changed status to true
    def force_attribute_change
      target.class.delegated_attributes.keys.each do |term|
        target.send(term+"_will_change!")
      end
    end

  end
end
