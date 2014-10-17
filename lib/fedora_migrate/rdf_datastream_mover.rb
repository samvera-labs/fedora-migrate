module FedoraMigrate
  class RDFDatastreamMover < Mover

    def migrate
      parser = FedoraMigrate::RDFDatastreamParser.new(target.uri, source.content)
      parser.parse
      parser.statements.each do |statement|
        target.resource << statement
      end
      target.save
    end

  end
end
