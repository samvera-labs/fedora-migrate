module FedoraMigrate
  class DatastreamMover < Mover

    attr_accessor :versionable

    def post_initialize
      raise StandardError, "You must supply a target" if target.nil?
    end

    def versionable?
      versionable.nil? ? target_versionable? : versionable
    end

    def target_versionable?
      if target.respond_to?(:versionable?)
        target.versionable?
      else 
        false
      end
    end
    
    def migrate
      if versionable?
        migrate_versions
      else
        migrate_current
      end
    end

    private

    # Reloading the target, otherwise #get_checksum is nil
    def migrate_current
      migrate_content
      target.reload
      verify
    end

    def migrate_versions
      source.versions.each do |version|
        migrate_content(version)
        target.create_version
        verify(version)
      end
    end

    # TODO: lastModified isn't the right place for the original creation date
    def migrate_content datastream=nil
      datastream ||= source
      target.content = datastream.content
      target.original_name = datastream.label
      target.mime_type = datastream.mimeType
      target.last_modified = datastream.createDate
      target.save
    end

    def verify datastream=nil
      datastream ||= source
      target_checksum = get_checksum
      unless datastream.checksum == target_checksum.split(/:/).last
        raise StandardError, "Checksum mismatch"
      end
    end

    # waiting on projecthydra/active_fedora#489
    def get_checksum
      predicate = RDF::URI.new("http://fedora.info/definitions/v4/rest-api#digest")
      query = target.container_resource.query([RDF::URI.new(target.container_resource.content_path), predicate, nil])
      query.first.object.object[:path]
    end

  end

end
