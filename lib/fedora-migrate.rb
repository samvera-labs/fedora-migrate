require "fedora_migrate/version"
require "active_support"
require "active_fedora"

module FedoraMigrate
  extend ActiveSupport::Autoload

  autoload :RubydoraConnection
  autoload :TripleConverter
  autoload :RDFDatastreamParser

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

end
