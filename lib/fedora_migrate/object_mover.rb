module FedoraMigrate
  class ObjectMover < Mover

    RIGHTS_DATASTREAM = "rightsMetadata".freeze

    ContentDatastreamReport = Struct.new(:ds, :versions)
    RDFDatastreamReport = Struct.new(:ds, :status)
    Report = Struct.new(:id, :class, :content_datastreams, :rdf_datastreams, :permissions, :dates)

    def migrate
      prepare_target
      conversions.collect { |ds| convert_rdf_datastream(ds) }
      migrate_datastreams
      complete_target
      super
    end

    def post_initialize
      conversion_options
      create_target_model if target.nil?
    end

    def results_report
      Report.new.tap do |report|
        report.content_datastreams = []
        report.rdf_datastreams = []
      end
    end

    def prepare_target
      report.class = target.class.to_s
      report.id = target.id
      before_object_migration
    end

    def complete_target
      after_object_migration
      save
    end

    private

    def migrate_datastreams
      migrate_content_datastreams
      migrate_permissions
      migrate_dates
    end

    # We have to call save before migrating content datastreams, otherwise versions aren't recorded
    # TODO: this will fail if required fields are defined in a descMetadata datastream that is not
    # converted to RDF (issue #8)
    def migrate_content_datastreams
      save
      target.attached_files.keys.each do |ds|
        mover = FedoraMigrate::DatastreamMover.new(source.datastreams[ds.to_s], target.attached_files[ds.to_s], options)
        report.content_datastreams << ContentDatastreamReport.new(ds, mover.migrate)
      end
    end

    def convert_rdf_datastream ds
      if source.datastreams.key?(ds)
        mover = FedoraMigrate::RDFDatastreamMover.new(datastream_content(ds), target)
        report.rdf_datastreams << RDFDatastreamReport.new(ds, mover.migrate)
      end
    end

    def datastream_content(dsid)
      source.datastreams[dsid.to_s]
    end

    def migrate_permissions
      if source.datastreams.keys.include?(RIGHTS_DATASTREAM) && target.respond_to?(:permissions)
        mover = FedoraMigrate::PermissionsMover.new(source.datastreams[RIGHTS_DATASTREAM], target)
        report.permissions = mover.migrate
      end
    end

    def migrate_dates
      report.dates = FedoraMigrate::DatesMover.new(source, target).migrate
    end

    def create_target_model
      builder = FedoraMigrate::TargetConstructor.new(source.models).build
      raise FedoraMigrate::Errors::MigrationError, "No qualified targets found in #{source.pid}" if builder.target.nil?
      @target = builder.target.new(id: id_component)
    end

  end
end
