module FedoraMigrate
  class RDFDatastreamMover < Mover

    def migrate
      Logger.info "converting datastream '#{source.dsid}' to RDF"
      before_rdf_datastream_migration
      migrate_rdf_triples
      after_rdf_datastream_migration
      save
    end

    def migrate_rdf_triples
      target.resource << RDF::Reader.for(:ntriples).new(source.content.gsub(/<.+#{source.pid}>/,"<#{target.uri}>"))
    end

  end
end
