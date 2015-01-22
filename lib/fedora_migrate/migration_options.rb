module FedoraMigrate
  module MigrationOptions

    attr_accessor :options, :conversions

    def conversion_options
      self.conversions = options.nil? ? [] : [options[:convert]].flatten      
    end

    def forced?
      options[:force] || false
    end

    def not_forced?
      !forced?
    end

  end
end
