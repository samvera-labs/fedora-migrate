require "fedora_migrate/version"
require "active_support"
require "active_fedora"
require "hydra/head"
require "rubydora"

# Loads rake tasks
Dir[File.expand_path(File.join(File.dirname(__FILE__), "tasks/*.rake"))].each { |ext| load ext } if defined?(Rake)

module FedoraMigrate
  extend ActiveSupport::Autoload

  autoload :ContentMover
  autoload :DatastreamMover
  autoload :DatastreamVerification
  autoload :DatesMover
  autoload :Errors
  autoload :FileConfigurator
  autoload :Hooks
  autoload :Logger
  autoload :MigrationOptions
  autoload :MigrationReport
  autoload :Mover
  autoload :ObjectMover
  autoload :Permissions
  autoload :PermissionsMover
  autoload :RDFDatastreamMover
  autoload :RDFDatastreamParser
  autoload :RelsExtDatastreamMover
  autoload :RepositoryMigrator
  autoload :RightsMetadata
  autoload :RubydoraConnection
  autoload :TargetConstructor
  autoload :TripleConverter

  class << self
    attr_reader :fedora_config, :source
    attr_accessor :configurator

    def fedora_config
      @fedora_config ||= ActiveFedora::Config.new(configurator.fedora3_config)
    end

    def source
      @source ||= FedoraMigrate::RubydoraConnection.new(fedora_config.credentials)
    end

    def find(id)
      FedoraMigrate.source.connection.find(id)
    end

    def migrate_repository(args)
      migrator = FedoraMigrate::RepositoryMigrator.new(args[:namespace], args[:options])
      migrator.migrate_objects
      migrator.migrate_relationships
      migrator
    end
  end

  self.configurator ||= FedoraMigrate::FileConfigurator.new
end
