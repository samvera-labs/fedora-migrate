module FedoraMigrate
  class FileConfigurator < ActiveFedora::FileConfigurator

    def fedora3_config
      load_fedora3_config
      @fedora_config
    end

    def load_fedora3_config
      return @fedora_config unless @fedora_config.empty?
      @fedora_config_path = get_config_path(:fedora3)
      Logger.info("loading fedora config from #{::File.expand_path(@fedora_config_path)}")

      begin
        config_erb = ERB.new(IO.read(@fedora_config_path)).result(binding)
      rescue Exception => e
        raise("fedora.yml was found, but could not be parsed with ERB. \n#{$!.inspect}")
      end

      begin
        fedora_yml = YAML.load(config_erb)
      rescue Psych::SyntaxError => e
        raise "fedora.yml was found, but could not be parsed. " \
              "Error #{e.message}"
      end

      config = fedora_yml.symbolize_keys

      cfg = config[ActiveFedora.environment.to_sym] || {}
      @fedora_config = cfg.kind_of?(Array) ? cfg.map(&:symbolize_keys) : cfg.symbolize_keys
    end

  end
end
