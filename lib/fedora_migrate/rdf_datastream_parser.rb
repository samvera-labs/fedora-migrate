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
        build_statement(triple) unless triple.predicate.nil?
      end
    end

    private

    def build_statement triple
      statement = RDF::Statement(RDF::URI.new(subject), triple.predicate, triple.object)
      Logger.info "using converted rdf triple #{statement}"
      statements << statement
    end

  end

end
