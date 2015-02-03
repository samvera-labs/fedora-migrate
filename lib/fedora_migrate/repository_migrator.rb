module FedoraMigrate
  class RepositoryMigrator

    include MigrationOptions

    attr_accessor :source_objects, :namespace, :failed

    def initialize namespace = nil, options = {}
      @namespace = namespace || repository_namespace
      @options = options
      @failed = 0
      @source_objects = get_source_objects
      conversion_options
    end

    # TODO: need a reporting mechanism for results (issue #4)
    def migrate_objects
      source_objects.each { |source| migrate_object(source) }
      @failed == 0
    end

    # TODO: need a reporting mechanism for results (issue #4)
    def migrate_relationships
      return "Relationship migration halted because #{failed.to_s} objects didn't migrate successfully." if failed > 0 && not_forced?
      source_objects.each { |source| migrate_relationship(source) }
      @failed == 0
    end

    def get_source_objects
      FedoraMigrate.source.connection.search(nil).collect { |o| qualifying_object(o) }.compact
    end

    private

    def migrate_object source
      Logger.info "Migrating source object #{source.pid}"
      FedoraMigrate::ObjectMover.new(source, nil, options).migrate
    rescue StandardError => e
      Logger.warn "#{source.pid} failed.\n#{error_message(e)}"
      @failed = @failed + 1
    end

    def migrate_relationship source
      Logger.info "Migrating relationships for source object #{source.pid}"
      FedoraMigrate::RelsExtDatastreamMover.new(source).migrate
    rescue StandardError => e
      Logger.warn "#{source.pid} relationship migration failed.\n#{error_message(e)}"
      @failed = @failed + 1
    end

    def error_message e
      [e.inspect, e.backtrace.join("\n\t")].join("\n\t")
    end

    def repository_namespace
      FedoraMigrate.source.connection.repository_profile["repositoryPID"]["repositoryPID"].split(/:/).first.strip
    end

    def qualifying_object object
      name = object.pid.split(/:/).first
      return object if name.match(namespace)
    end

  end
end
