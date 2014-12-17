module FedoraMigrate
  class RDFDatastreamParser

    attr_accessor :subject, :datastream, :statements

    def initialize subject, content
      @subject = subject
      @datastream = content
      @statements = []
    end

    def parse
      datastream.split(/\n/).each do |s|
        triple = FedoraMigrate::TripleConverter.new(s)
        statement = RDF::Statement(RDF::URI.new(subject), triple.predicate, triple.object)
        Logger.info "converting: \n\t#{s} to \n\t#{statement}"
        statements << statement
      end
    end

  end

end
