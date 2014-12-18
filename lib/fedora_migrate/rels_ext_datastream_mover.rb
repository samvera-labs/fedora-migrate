require 'rubydora'
module FedoraMigrate
  class RelsExtDatastreamMover < Mover

    attr_accessor :relationships, :ng_xml, :subject

    RELS_EXT = Rubydora::RelationshipsMixin::RELS_EXT
    RELS_EXT_DATASTREAM = "RELS-EXT".freeze

    def post_initialize
      retrieve_subject
      @relationships ||= {}
      @ng_xml = Nokogiri::XML(source.datastreams[RELS_EXT_DATASTREAM].content)
      parse_relationships if has_relationships?
    end

    def has_relationships?
      source.datastreams.keys.include?(RELS_EXT_DATASTREAM)
    end

    def migrate
      relationships.each do |predicate, objects|
        unless objects.empty?
          objects.collect { |object| migrate_relationship(predicate, object) }
        end
      end
    end

    private

    # because of projecthydra/rubydora#90 
    def parse_relationships
      RELS_EXT.keys.each do |key|
        query = "//ns0:"+RELS_EXT[key].split(/#/).last
        relationships[key.to_sym] = query_results(query)
      end
    end

    def query_results query, results = Array.new
      ng_xml.xpath(query).each do |predicate|
        results << retrieve_object(predicate.attribute("resource").text.split(/:/).last)
      end
      return results
    end

    def retrieve_subject
      @subject = ActiveFedora::Base.find(source.pid.split(/:/).last)
    rescue ActiveFedora::ObjectNotFoundError
      raise FedoraMigrate::Errors::MigrationError, "Source was not found in Fedora4. Did you migrated it?"
    end

    def retrieve_object id
      object = ActiveFedora::Base.find(id)
    rescue ActiveFedora::ObjectNotFoundError
      raise FedoraMigrate::Errors::MigrationError, "Could not find object with id #{id}"
    end

    def migrate_relationship predicate, object
      object.reflections.each do |key, association|
        unless association.predicate.to_s.split(/#/).empty?
          if association.predicate.to_s.split(/#/).last.gsub(/is/,"").underscore == predicate.to_s
            object.send(key.to_s) << subject
          end
        end
      end
    end

  end
end
