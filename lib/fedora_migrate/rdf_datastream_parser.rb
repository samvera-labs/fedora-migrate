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
        statements << RDF::Statement(RDF::URI.new(subject), triple.predicate, triple.object)
      end
    end

  end

end
