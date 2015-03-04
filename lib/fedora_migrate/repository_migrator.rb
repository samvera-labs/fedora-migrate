module FedoraMigrate
  class RepositoryMigrator

    include MigrationOptions

    attr_accessor :source_objects, :namespace, :report

    SingleObjectReport = Struct.new(:status, :object, :relationships)

    def initialize namespace = nil, options = {}
      @namespace = namespace || repository_namespace
      @options = options
      @report = MigrationReport.new(@options.fetch(:report, nil))
      @source_objects = get_source_objects
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
      if report.empty?
        FedoraMigrate.source.connection.search(nil).collect { |o| qualifying_object(o) }.compact
      else
        report.failed_objects.map { |o| FedoraMigrate.source.connection.find(o) }
      end
    end

    def failures
      report.failed_objects.count
    end

    private

    def migrate_object source
      object_report = SingleObjectReport.new
      begin
        object_report.object = FedoraMigrate::ObjectMover.new(source, nil, options).migrate
        object_report.status = true
      rescue StandardError => e
        object_report.object = e.inspect
        object_report.status = false
      end
      report.results[source.pid] = object_report
    end

    def migrate_relationship source
      relationship_report = find_or_create_single_object_report(source)
      begin
        relationship_report.relationships = FedoraMigrate::RelsExtDatastreamMover.new(source).migrate
        relationship_report.status = true
      rescue StandardError => e
        relationship_report.relationships = e.inspect
        relationship_report.status = false
      end
      report.results[source.pid] = relationship_report
    end

    def repository_namespace
      FedoraMigrate.source.connection.repository_profile["repositoryPID"]["repositoryPID"].split(/:/).first.strip
    end

    def qualifying_object object
      name = object.pid.split(/:/).first
      return object if name.match(namespace)
    end

    def find_or_create_single_object_report source
      report.results[source.pid] || SingleObjectReport.new
    end
  end
end
