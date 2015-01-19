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
      source_objects.each do |source|
        Logger.info "Migrating source object #{source.pid}"
        result = begin
          FedoraMigrate::ObjectMover.new(source, nil, options).migrate
        rescue NameError => e
          "The most likely explanation is that your target is not defined"
          error_message(e)
        rescue StandardError => e
          error_message(e)
        end
        unless result == true
          Logger.warn "#{source.pid} failed.\n#{result}"
          @failed = @failed + 1
        end
      end
    end

    # TODO: need a reporting mechanism for results (issue #4)
    def migrate_relationships
      return "Reltionship migration halted because #{failed.to_s} objects didn't migrate successfully." if failed > 0
      source_objects.each do |source|
        Logger.info "Migrating relationships for source object #{source.pid}"
        begin
          FedoraMigrate::RelsExtDatastreamMover.new(source).migrate
        rescue StandardError => e
          Logger.warn "#{source.pid} relationship migration failed.\n#{error_message(e)}"
        end
      end
    end

    # TODO: page through all the objects (issue #6)
    def get_source_objects
      FedoraMigrate.source.connection.search(nil).collect { |o| qualifying_object(o) }.compact
    end

    private

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
