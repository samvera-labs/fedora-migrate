module FedoraMigrate
  class DatastreamMover

    attr_accessor :source, :target, :versionable

    def initialize args={}
      @source = args[:source]
      @target = args[:target]
      @versionable = args[:versionable]
    end

    def is_versionable?
      @versionable || false
    end
    
    def migrate
      if is_versionable?
        migrate_versions
      else
        migrate_content
      end
    end

    private

    def migrate_versions
      source.versions.each do |version|
        migrate_content(version)
        target.create_version
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
      verify
    end 

    def verify
      # TODO
    end

  end

end
