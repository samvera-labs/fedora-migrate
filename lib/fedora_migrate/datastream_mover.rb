module FedoraMigrate
  class DatastreamMover < Mover

    attr_accessor :versionable

    def post_initialize
      raise FedoraMigrate::Errors::MigrationError, "You must supply a target" if target.nil?
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
      before_datastream_migration
      migrate_datastream
      after_datastream_migration
    end

    private

    def migrate_datastream
      if versionable?
        migrate_versions
      else
        migrate_current
      end
    end

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

    def migrate_content datastream=nil
      datastream ||= source
      if datastream.content.nil?
        Logger.info "datastream '#{datastream.dsid}' is nil. It's probably defined in the target but not present in the source"
        return true
      end
      target.content = datastream.content
      target.original_name = datastream.label
      target.mime_type = datastream.mimeType
      Logger.info "#{target.inspect}"
      save
    end

    # TODO: Reporting mechanism? If there isn't a checksum it defaults to "none" (issue #4)
    def verify datastream=nil
      datastream ||= source
      target_checksum = get_checksum
      return true if datastream.checksum == "none"
      unless datastream.checksum == target_checksum.split(/:/).last
        Logger.warn "expected #{datastream.dsid} #{datastream.checksumType} #{datastream.checksum} to match #{target_checksum}"
      end
    end

    def get_checksum
      target.digest.first.to_s
    end

  end

end
