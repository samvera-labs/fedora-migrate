module FedoraMigrate
  class RepositoryMigrator

    include MigrationOptions

    attr_accessor :source_objects, :namespace, :report

    Report = Struct.new(:status, :object, :relationships)

    def initialize namespace = nil, options = {}
      @namespace = namespace || repository_namespace
      @options = options
      @source_objects = get_source_objects
      @report = @options.fetch(:report, Hash.new)
      conversion_options
    end

    def migrate_objects
      source_objects.each { |source| migrate_object(source) }
    end

    def migrate_relationships
      return "Relationship migration halted because #{failures.to_s} objects didn't migrate successfully." if failures > 0 && not_forced?
      source_objects.each { |source| migrate_relationship(source) }
    end

    def get_source_objects
      FedoraMigrate.source.connection.search(nil).collect { |o| qualifying_object(o) }.compact
    end

    def failures
      report.map { |k,v| 1 unless v.status == true }.compact.count
    end

    private

    def migrate_object source
      object_report = Report.new
      begin
        object_report.object = FedoraMigrate::ObjectMover.new(source, nil, options).migrate
        object_report.status = true
      rescue StandardError => e
        object_report.object = e.inspect
        object_report.status = false
      end
      report[source.pid] = object_report
    end

    def migrate_relationship source
      relationship_report = find_or_create_report(source)
      begin
        relationship_report.relationships = FedoraMigrate::RelsExtDatastreamMover.new(source).migrate
        relationship_report.status = true
      rescue StandardError => e
        relationship_report.relationships = e.inspect
        relationship_report.status = false
      end
      report[source.pid] = relationship_report
    end

    def repository_namespace
      FedoraMigrate.source.connection.repository_profile["repositoryPID"]["repositoryPID"].split(/:/).first.strip
    end

    def qualifying_object object
      name = object.pid.split(/:/).first
      return object if name.match(namespace)
    end

    def find_or_create_report source
      report[source.pid] || Report.new
    end

  end
end
