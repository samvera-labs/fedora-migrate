require "fedora_migrate/version"
require "active_support"
require "active_fedora"
require "hydra-core"

# Loads rake tasks
Dir[File.expand_path(File.join(File.dirname(__FILE__),"tasks/*.rake"))].each { |ext| load ext } if defined?(Rake)

# Shenanigans because we're not in a Rails environment and we need
# Hydra::AccessControls
Hydra::Engine.config.autoload_paths.each { |path| $LOAD_PATH.unshift path }
# in gem version 2.4, .find_by_name isn't pulling up gems given in the Gemfile
# as opposed to those in the gemspec file.
# This is a workaround:
Gem::Specification.all.each do |g|
  HAC_DIR = g.gem_dir if g.name.match("hydra-access-controls")
end
require HAC_DIR+'/app/vocabularies/acl'
require HAC_DIR+'/app/vocabularies/hydra/acl'
require HAC_DIR+'/app/models/role_mapper'
require HAC_DIR+'/app/models/ability'
require HAC_DIR+'/app/models/hydra/access_controls/access_control_list'
require HAC_DIR+'/app/models/hydra/access_controls/permission'
require HAC_DIR+'/app/models/hydra/access_controls/embargo'
require HAC_DIR+'/app/models/hydra/access_controls/lease'
require HAC_DIR+'/app/services/hydra/lease_service'
require HAC_DIR+'/app/services/hydra/embargo_service'
require HAC_DIR+'/app/validators/hydra/future_date_validator'

module FedoraMigrate
  extend ActiveSupport::Autoload

  autoload :DatastreamMover
  autoload :Errors
  autoload :Hooks
  autoload :Logger
  autoload :MigrationOptions
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
  autoload :TripleConverter

  class << self
    attr_reader :fedora_config, :config_options, :source
  end

  def self.fedora_config
    @fedora_config ||= default_fedora_config
  end

  def self.config_options
    @config_options ||= "comming soon!"
  end

  def self.source
    @source ||= FedoraMigrate::RubydoraConnection.new(fedora_config)
  end 

  # TODO: move to separate class with yaml file for config
  def self.default_fedora_config
    {
      url: "http://localhost:8983/fedora3",
      user: "fedoraAdmin",
      password: "fedoraAdmin"
    }
  end

  def self.find id
    FedoraMigrate.source.connection.find(id)
  end

  def self.migrate_repository args
    migrator = FedoraMigrate::RepositoryMigrator.new(args[:namespace], args[:options])
    migrator.migrate_objects
    migrator.migrate_relationships
    migrator.results
  end

end
