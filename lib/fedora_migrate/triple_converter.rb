module FedoraMigrate
  class TripleConverter

    attr_accessor :statement, :term

    def initialize statement
      @statement = statement
      @term = dc_term_from_predicate
    end

    def object
      verify_object
      statement.split(/"/)[1]
    end 

    def predicate
      if ::RDF::DC.respond_to?(term)
        ::RDF::DC.send(term)
      else
        Logger.warn "tried to add #{object} using the term #{term}, but it doesn't appear to be in RDF::DC"
      end
    end

    def verify_object
      unless statement.match(/"/)
        Logger.warn "expected a RDF triple statement separated with double-quotes"
      end
    end

    private

    def dc_term_from_predicate
      url = statement.split(/ /)[1].gsub(/<|>/,"")
      URI(url).path.split("/").last
    end

  end

end
