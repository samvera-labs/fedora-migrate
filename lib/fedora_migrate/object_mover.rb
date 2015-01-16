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
      if source.datastreams.keys.include?(ds)
        mover = FedoraMigrate::RDFDatastreamMover.new(source.datastreams[ds.to_s], target)
        mover.migrate
      end
    end

    def migrate_permissions
      if source.datastreams.keys.include?(RIGHTS_DATASTREAM) && target.respond_to?(:permissions)
        mover = FedoraMigrate::PermissionsMover.new(source.datastreams[RIGHTS_DATASTREAM], target)
        mover.migrate
      end
    end

    def create_target_model
      afmodel = source.models.map { |m| m if m.match(/afmodel/) }.compact.first.split(/:/).last
      Logger.info "found #{afmodel} in source object #{source.pid}"
      @target = afmodel.constantize.new(id: source.pid.split(/:/).last)
    end

  end
  
end
