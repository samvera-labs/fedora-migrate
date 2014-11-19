module FedoraMigrate
  class RDFDatastreamMover < Mover

    def migrate
      parser = FedoraMigrate::RDFDatastreamParser.new(target.uri, source.content)
      parser.parse
      parser.statements.each do |statement|
        target.resource << statement
      end
      force_attribute_change
      target.save
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
