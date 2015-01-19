module FedoraMigrate
  class DatastreamMover < Mover

    include DatastreamVerification

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

    # Reload the target, otherwise the checksum is nil
    def migrate_current
      migrate_content
      target.reload
      valid?
    end

    def migrate_versions
      source.versions.each do |version|
        migrate_content(version)
        target.create_version
        valid?(version)
      end
    end

    def migrate_content datastream=nil
      datastream ||= source
      if datastream.content.nil?
        Logger.info "datastream '#{datastream.dsid}' is nil. It's probably defined in the target but not present in the source"
        return true
      end
      target.content = datastream.content
      target.original_name = datastream.label.try(:gsub, /"/, '\"')
      target.mime_type = datastream.mimeType
      Logger.info "#{target.inspect}"
      save
    end

  end

end
