module FedoraMigrate
  class RepositoryMigrator

    include MigrationOptions

    attr_accessor :source_objects, :namespace, :report, :source, :result

    SingleObjectReport = Struct.new(:status, :object, :relationships)

    def initialize namespace = nil, options = {}
      @namespace = namespace || repository_namespace
      @options = options
      @report = MigrationReport.new(@options.fetch(:report, nil))
      @source_objects = get_source_objects
      conversion_options
    end

    def migrate_objects
      source_objects.each do |object|
        @source = object
        migrate_current_object
      end
      report.reload
    end

    def migrate_current_object
      return unless migration_required?
      initialize_report
      migrate_object
    end

    def initialize_report
      @result = SingleObjectReport.new
      @result.status = false
      report.save(source.pid, @result)
    end

    def migrate_relationships
      return "Relationship migration halted because #{failures.to_s} objects didn't migrate successfully." if failures > 0 && not_forced?
      source_objects.each do |object|
        @source = object
        @result = find_or_create_single_object_report
        migrate_relationship unless blacklist.include?(source.pid)
      end
    end

    def get_source_objects
      FedoraMigrate.source.connection.search(nil).collect { |o| qualifying_object(o) }.compact
    end

    def failures
      report.failed_objects.count
    end

    private

    def migrate_object
      result.object = FedoraMigrate::ObjectMover.new(source, nil, options).migrate
      result.status = true
    rescue StandardError => e
      result.object = e.inspect
      result.status = false
    ensure
      report.save(source.pid, result)
    end

    def migrate_relationship
      result.relationships = FedoraMigrate::RelsExtDatastreamMover.new(source).migrate
      result.status = true
    rescue StandardError => e
      result.relationships = e.inspect
      result.status = false
    ensure
      report.save(source.pid, result)
    end

    def repository_namespace
      FedoraMigrate.source.connection.repository_profile["repositoryPID"]["repositoryPID"].split(/:/).first.strip
    end

    def qualifying_object object
      name = object.pid.split(/:/).first
      return object if name.match(namespace)
    end

    def migration_required?
      return false if blacklist.include?(source.pid)
      return true if report.results[source.pid].nil?
      !report.results[source.pid]["status"]
    end

    def find_or_create_single_object_report
      if report.results[source.pid].nil?
        SingleObjectReport.new
      else
        SingleObjectReport.new(report.results[source.pid]["status"],report.results[source.pid]["object"],report.results[source.pid]["relationships"])
      end
    end

  end
end
