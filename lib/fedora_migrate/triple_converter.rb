module FedoraMigrate
  class TripleConverter

    attr_accessor :statement

    def initialize statement
      @statement = statement
    end

    def object
      verify_object
      statement.split(/"/)[1]
    end 

    def predicate
      RDF::DC.send(dc_term_from_predicate)
    end

    def verify_object
      unless statement.match(/"/)
        raise StandardError, "Expecting the object in the RDF triple statement to be separated with double-quotes"
      end
    end

    private

    def dc_term_from_predicate
      url = statement.split(/ /)[1].gsub(/<|>/,"")
      URI(url).path.split("/").last
    end

  end

end
