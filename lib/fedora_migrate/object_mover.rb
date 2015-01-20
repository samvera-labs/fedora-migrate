module FedoraMigrate
  class ObjectMover < Mover

    RIGHTS_DATASTREAM = "rightsMetadata".freeze

    def migrate
      prepare_target
      conversions.collect { |ds| convert_rdf_datastream(ds) }
      migrate_content_datastreams
      migrate_permissions
      complete_target
    end

    def post_initialize
      conversion_options
      create_target_model if target.nil?
    end

    def prepare_target
      Logger.info "running before_object_migration hooks"
      before_object_migration
    end

    def complete_target
      Logger.info "running after_object_migration hooks"
      after_object_migration
      save
    end

    private

    # We have to call save before migrating content datastreams, otherwise versions aren't recorded
    # TODO: this will fail if required fields are defined in a descMetadata datastream that is not
    # converted to RDF (issue #8)
    def migrate_content_datastreams
      save
      target.attached_files.keys.each do |ds|
        mover = FedoraMigrate::DatastreamMover.new(source.datastreams[ds.to_s], target.attached_files[ds.to_s])
        mover.migrate
      end
    end

    def convert_rdf_datastream ds
      if source.datastreams.key?(ds)
        mover = FedoraMigrate::RDFDatastreamMover.new(datastream_content(ds), target)
        mover.migrate
      end
    end

    def datastream_content(dsid)
      source.datastreams[dsid.to_s]
    end

    def migrate_permissions
      if source.datastreams.keys.include?(RIGHTS_DATASTREAM) && target.respond_to?(:permissions)
        mover = FedoraMigrate::PermissionsMover.new(source.datastreams[RIGHTS_DATASTREAM], target)
        mover.migrate
      end
    end

    def create_target_model
      builder = FedoraMigrate::TargetConstructor.new(@source.models).build
      raise FedoraMigrate::Errors::MigrationError, "No qualified targets found in #{@source.pid}" if builder.target.nil?
      @target = builder.target.new(id: @source.pid.split(/:/).last)
    end

  end
end
