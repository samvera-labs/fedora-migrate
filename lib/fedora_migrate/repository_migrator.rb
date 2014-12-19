module FedoraMigrate
  class RepositoryMigrator

    include MigrationOptions

    attr_accessor :source_objects, :results, :namespace

    def initialize namespace = nil, options = {}
      @namespace = namespace || repository_namespace
      @options = options
      @source_objects = get_source_objects
      @results = []
      conversion_options
    end

    def migrate_objects
      source_objects.each do |source|
        Logger.info "Migrating source object #{source.pid}"
        begin
          results << { source.pid => [FedoraMigrate::ObjectMover.new(source, nil, options).migrate] }
        rescue NameError => e
          results << { source.pid => e.to_s }
        rescue FedoraMigrate::Errors::MigrationError => e
          results << { source.pid => e.to_s }
        end
      end
    end

    # TODO: need a reporting mechanism for results (issue #4)
    def migrate_relationships
      source_objects.each do |source|
        Logger.info "Migrating relationships for source object #{source.pid}"
        begin
          FedoraMigrate::RelsExtDatastreamMover.new(source).migrate
        rescue FedoraMigrate::Errors::MigrationError => e
          results << { source.pid => e.to_s }
        rescue ActiveFedora::AssociationTypeMismatch => e
          results << { source.pid => e.to_s }
        end
      end
    end

    # TODO: page through all the objects (issue #6)
    def get_source_objects
      FedoraMigrate.source.connection.search(nil).collect { |o| qualifying_object(o) }.compact
    end

    private

    def repository_namespace
      FedoraMigrate.source.connection.repository_profile["repositoryPID"]["repositoryPID"].split(/:/).first.strip
    end

    def qualifying_object object
      name = object.pid.split(/:/).first
      return object if name.match(namespace)
    end

  end
end
