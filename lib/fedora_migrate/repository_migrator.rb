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
        results << { source.pid => [FedoraMigrate::ObjectMover.new(source, nil, options).migrate] }
      end
    end

    # TODO: need a reporting mechanism for results
    def migrate_relationships
      source_objects.each do |source|
        FedoraMigrate::RelsExtDatastreamMover.new(source).migrate
      end
    end

    # TODO: pretty sure search results are paged so we'd need
    # page through all the results or only migrate a page
    # at a time.
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
